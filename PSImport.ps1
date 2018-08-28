<#
.SYNOPSIS
PSImport.ps1 - Granfeldt PSMA import processor for Azure AD user (and B2B guest user objects)
.DESCRIPTION
This script uses the AzureAD PowerShell module to retrieve, process and import object into the MIM connectorspace.
.LINK
http://www.integralis.co.za
https://github.com/puttyq/mim.azureb2b.managementagent
https://github.com/sorengranfeldt/psma
.NOTES
Almero Steyn - almero@iitcon.co.za
#>

param (
    $Username,
	$Password,
    $Credentials,
	$OperationType,
    [bool] $usepagedimport,
	$pagesize
    )

BEGIN {
#region *** Configuration ***

    # clear error variable
    $error.clear()

    # convert import credentails to #cred
    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

    # read configuration settings
    [xml]$ConfigFile = Get-Content "C:\AzureB2BSync\psma.scripts\PSMA_B2B_Settings.xml"

    # enable error logging
    [bool]$logging = [System.Convert]::ToBoolean($ConfigFile.settings.logging.loggingEnabled)
    [string]$logLocation = $ConfigFile.settings.logging.filePath + $ConfigFile.settings.logging.fileNameImport
    [bool]$logVerbose = $ConfigFile.settings.logging.loggingVerbose

    # get user import variables
    # userType - 'All' for all user types, 'Member' for Azure AD Users and 'Guest' for B2B users
    # manager - Get-AzureADManager
    # photo - Get-AzureADUserThumbnailPhoto
    [string]$usersType = $ConfigFile.settings.import.userFilterType
    [string]$userManager = $ConfigFile.settings.import.userFilterManager
    [string]$userExoHideAddressList = $ConfigFile.settings.import.userExoHideAddressList
    [string]$userPhoto = $ConfigFile.settings.import.userFilterPhoto
    [string]$userPhotoPath = $ConfigFile.settings.import.userThumbnailPath
    [string]$legacyExchangeDNcloud = $ConfigFile.settings.import.getTenantLEDN

    # restirict only syncing users with property 'ImmutableId' set and not null
    [bool]$restrictImmutableId = [System.Convert]::ToBoolean($ConfigFile.settings.import.userFilterRestrictImmutableId)

    # exchange online URI
    [string]$exoURI = $ConfigFile.settings.connection.exchangeOnlineURI

#endregion

#region ***  Functions and Debugging File ***

    # function to log messages to custom log file
    Function log([string]$message, [string]$level) {
        if ($logging) {
            if ($message) {
                if ($level.ToUpper() -eq "ERROR") {
                    $message = (Get-date).ToString() + " - [ERROR] -- " + $message
                    Write-Error $message
                } elseif (($level -eq "DEBUG") -and ($logVerbose -eq $True)) {
                    $message = (Get-date).ToString() + " - [DEBUG] -- " + $message
                    Write-Debug $message
                } else {
                    $message = (Get-date).ToString() + " - [INFO] -- " + $message
                    Write-Information $message
                }
                # log file location
                $message | out-file $logLocation -append
		    }
        }
    }

#endregion

#region *** Load Modules and Connect to AzureAD ***

    log -message ("Run Profile Starting (" + $OperationType + ")") -level "INFO"
    log -message ("Loading AzureAD Module") -level "DEBUG"

    # Import Modules
    $error.Clear()
    Import-Module "AzureAD" -ErrorAction SilentlyContinue

    # Check for errors in Loading AzureAD module
    If (!$error) {
        log -message ("AzureAD Module Installed") -level "DEBUG"
    }
    else {
        log -message ("AzureAD Module NOT Installed, trying to install") -level "ERROR"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$False
        log -message ("NuGet Module Installed") -level "DEBUG"
        Install-Module -Name AzureAD -Force -Confirm:$False
        log -message ("AzureAD Module Installed") -level "DEBUG"
        Import-Module -Name AzureAD
        log -message ("AzureAD Module Imported") -level "DEBUG"
    }

    # Check is module is imported
    if ((Get-Module -Name "AzureAD")) {
        log -message ("AzureAD Module Imported") -level "DEBUG"
    } else {
        log -message ("AzureAD Module is NOT Imported") -level "ERROR"
    }

    # connects to Azure AD PowerShell Managment Shell
    log -message ("Connecting to AzureAD") -level "DEBUG"
    Connect-AzureAD -Credential $creds
    log -message ("Connected to AzureAD") -level "INFO"

    # Connect to Exchange Online (if cloud legacyExchangeDN from tenant source is required)
    if ($legacyExchangeDNcloud) {
        $excoPsSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exoURI -Credential $creds -Authentication "Basic" -AllowRedirection
        Import-PSSession $excoPsSession -AllowClobber
        log -message ("Exchange Online PS Session Imported") -level "INFO"
    }

#endregion
}

PROCESS {
#region *** Connection and Importing ***

    # get users result
    if($usersType -eq "Guest" -or $usersType -eq "Member") {
        $users = Get-AzureADUser -All $True | ? {$_.UserType -eq $usersType}
    } else {
        $users = Get-AzureADUser -All $True
    }

    log -message ("Retrieved Azure Users with type '" + $usersType + "' :" + $users.Count) -level "INFO"

    # an array for the retuned objects to go into
    if($restrictImmutableId) {
        $tenantObjects = $users | ? {$_.ImmutableId -ne $null}
        log -message ("Total Azure Users with type '" + $usersType + "' and ImmutableId set: " + $tenantObjects.count) -level "DEBUG"
    } else {
        $tenantObjects = $users
        log -message ("Total Azure Users with type '" + $usersType + "': " + $tenantObjects.count + " (Skipping ImmutableID check)") -level "DEBUG"
    }

#endregion

#region *** Process users into the MA ***

    ForEach($user in $tenantObjects) {
        
        $obj = @{}
        $obj.Add("ID", $user.ObjectId.toString())
        $obj.Add("objectID", $user.ObjectId.toString())

        # set objectClass
        if ($user.UserType -eq "Guest") {
            $obj.Add("objectClass", "AzureADGuest")
            if ($userExoHideAddressList -eq $True) {
                if ($excoPsSession.State -ne "Opened")
                {
                    Remove-PSSession $excoPsSession    
                    $excoPsSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exoURI -Credential $creds -Authentication "Basic" -AllowRedirection
                    Import-PSSession $excoPsSession -AllowClobber 
                    log -message ("Exchange Online PS Session Recreated") -level "INFO"                    
                }
                $exoHidden = Get-MailUser -Identity $user.UserPrincipalName | Select-Object HiddenFromAddressListsEnabled
                $obj.Add("ShowInAddressListExo", $exoHidden.HiddenFromAddressListsEnabled)
            }
        }  else {
            $obj.Add("objectClass", "AzureADUser")
        }

        $obj.Add("AccountEnabled",$user.AccountEnabled)
        $obj.Add("AgeGroup",$user.AgeGroup)
        $obj.Add("City",$user.City)
        $obj.Add("CompanyName",$user.CompanyName)
        $obj.Add("ConsentProvidedForMinor",$user.ConsentProvidedForMinor)
        $obj.Add("Country",$user.Country)
        $obj.Add("CreationType",$user.CreationType)
        $obj.Add("Department",$user.Department)
        $obj.Add("DisplayName",$user.DisplayName)
        $obj.Add("FacsimileTelephoneNumber",$user.FacsimileTelephoneNumber)
        $obj.Add("GivenName",$user.GivenName)
        $obj.Add("ImmutableId",$user.ImmutableId)
        $obj.Add("JobTitle",$user.JobTitle)
        $obj.Add("LegalAgeGroupClassification",$user.LegalAgeGroupClassification)
        $obj.Add("Mail",$user.Mail)
        $obj.Add("MailNickName",$user.MailNickName)
        $obj.Add("Mobile",$user.Mobile)
        # $obj.Add("OtherMails",$user.OtherMails) - OtherMails Not Implemented (Todo)
        $obj.Add("PhysicalDeliveryOfficeName",$user.PhysicalDeliveryOfficeName)
        $obj.Add("PostalCode",$user.PostalCode)
        $obj.Add("ShowInAddressList",$user.ShowInAddressList)
        $obj.Add("State",$user.State)
        $obj.Add("StreetAddress",$user.StreetAddress)
        $obj.Add("Surname",$user.Surname)
        $obj.Add("TelephoneNumber",$user.TelephoneNumber)
        $obj.Add("UsageLocation",$user.UsageLocation)
        $obj.Add("UserPrincipalName",$user.UserPrincipalName)
        $obj.Add("UserType",$user.UserType)
        $obj.Add("distinguishedName",$user.ExtensionProperty.onPremisesDistinguishedName)

        # retrieve on-premise SID
        if (($user.OnPremisesSecurityIdentifier -ne $Null) -and ($user.OnPremisesSecurityIdentifier.Count -gt 0)) {
            $BinarySid = $user.OnPremisesSecurityIdentifier[0].Key
            if($user.OnPremisesSecurityIdentifier[0].Key -ne $Null) {
                $obj.Add("sid",$BinarySid) # add the SID to the user in the connector space
            }
        }

        # create object for proxyAddresses
        if ($user.ProxyAddresses) {
            $proxyAddresses = @()
            foreach($address in $user.proxyAddresses) {
                $proxyAddresses += $address
            }
            $obj.Add("ProxyAddresses",($proxyAddresses))
        }

        # get user manager
        if ($userManager -eq $True) {
            $manager = Get-AzureADUserManager -ObjectId $user.ObjectId.toString()
            $obj.Add("Manager", $manager.ObjectId)
            $obj.Add("ManagerDisplayName", $manager.DisplayName)
            $obj.Add("ManagerUserPrincipleName", $manager.UserPrincipalName)
        }

        # get legacyExchangeDN from the tenant user (to support tenant to tenant migration)
        #if ($legacyExchangeDNcloud) {
        #    $ledn = Get-Mailbox -Identity $user.Mail | Select LegacyExchangeDN
        #}

        # get user photo - Not Implemented (Todo)
        # if ($userPhoto -eq $True)
        # {
        #     Get-AzureADUserThumbnailPhoto -ObjectId $user.ObjectId.toString() -FilePath $userPhotoPath -FileName $user.ObjectId.toString()
        #     $obj.Add("ThumbnailLocation", ($userPhotoPath + $user.objectID.toString() + ".jpeg"))
        # }

        # pass the object to the MA
        $obj
    }

#endregion
}

END {
    log -message ("Run Profile Complete (" + $OperationType + ")") -level "INFO"
}