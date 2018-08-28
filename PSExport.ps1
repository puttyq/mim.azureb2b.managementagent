<#
.SYNOPSIS
PSExport.ps1 - Export scripts for create, update and delete for AzureAD users objects.
.DESCRIPTION
The script contains the ability to export FIM/MIM simple objects to AzureAD (via AzureAD module) for the Granfeldt PSMA and caters for the following object types:
- user (add,replace,delete)
Credentials must be specific within the PSMA configuration. (These are passed as param's to the script but stored encrypted in the FIM/MIM DB)
.LINK
http://www.integralis.co.za
http://www.nbconsult.co
.NOTES
Almero Steyn - almero@iitcon.co.za
Version 0.9 - Base features
#>

PARAM (
    $Username,
    $Password,
    $Credentials,
    $OperationType
)

BEGIN
{

#region *** Configuration ***

    # convert import credentails to #cred
    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

    # read configuration settings
    [xml]$ConfigFile = Get-Content "C:\AzureB2BSync\psma.scripts\PSMA_B2B_Settings.xml"

    # enable error logging
    [bool]$logging = [System.Convert]::ToBoolean($ConfigFile.settings.logging.loggingEnabled)
    [string]$logLocation = $ConfigFile.settings.logging.filePath + $ConfigFile.settings.logging.fileNameExport
    [bool]$logVerbose = [System.Convert]::ToBoolean($ConfigFile.settings.logging.loggingVerbose)

    # AzureADMS invite settings
    [bool]$inviteEmail = [System.Convert]::ToBoolean($ConfigFile.settings.export.inviteEmailSending)
    [string]$inviteRedirectionURL = $ConfigFile.settings.export.inviteRedirectionURL

    # exchange online URI
    [string]$exoURI = $ConfigFile.settings.connection.exchangeOnlineURI

#endregion

#region ***  Functions and Debugging File ***

    # Function to log messages to custom log file
    Function log([string]$message, [string]$level) {
        if ($logging) {
            if ($message) {
                if ($level.ToUpper() -eq "ERROR") {
                    $message = (Get-date).ToString() + " - [ERROR] -- " + $message
                    Write-Error $message
                    $message | out-file $logLocation -append
                } elseif (($level.ToUpper() -eq "DEBUG") -and ($logVerbose -eq $True)) {
                    $message = (Get-date).ToString() + " - [DEBUG] -- " + $message
                    Write-Debug $message
                    $message | out-file $logLocation -append
                } elseif ($level.ToUpper() -eq "INFO") {
                    $message = (Get-date).ToString() + " - [INFO] -- " + $message
                    Write-Information $message
                    $message | out-file $logLocation -append
                }
		    }
        }
    }

    Function AzureADGuest-Add {
        log -message ("New-AzureADMSInvitation -InvitedUserDisplayName " + $DisplayName + " -InvitedUserEmailAddress " + $Mail + " -SendInvitationMessage " + $inviteEmail + "-InviteRedirectUrl $inviteRedirectionURL -InvitedUserType guest") -level "DEBUG"
        New-AzureADMSInvitation -InvitedUserDisplayName $DisplayName -InvitedUserEmailAddress $Mail -SendInvitationMessage $inviteEmail -InviteRedirectUrl $inviteRedirectionURL -InvitedUserType "guest" -ErrorAction Stop
        log -message ("Created Azure guest account for $UserPrincipalName") -level "INFO"
    }

    Function AzureADGuest-Replace-User {
        log -message ("Processing update to Azure guest account $UserPrincipalName") -level "DEBUG"

        # build update command for general information on AzureADGuest account
        $commandUpdate = "Set-AzureADUser -ObjectID $UserPrincipalName"
        foreach ($change in $attributeChanges) {
            if (($change -ne "Manager") -and ($change -ne "ProxyAddresses") -and ($change -ne "ThumbnailLocation") -and ($change -ne "ShowInAddressListExo")) {
                $commandUpdate += (" -" + $change + " $" + "$change")
            }
        }

        # execute update command to AzureAD
        log -message ("Command to be executed") -level "DEBUG"
        log -message ("$commandUpdate") -level "DEBUG"
        Invoke-Expression $commandUpdate -ErrorAction Stop
        log -message ("Updated general contact information on $UserPrincipalName") -level "INFO"
    }

    Function AzureADGuest-Replace-ProxyAddress {
        log -message ("Updating proxyAddresses via: Set-MailUser -Identity $UserPrincipalName -EmailAddresses $proxyAddresses") -level "DEBUG"
        Set-MailUser -Identity $UserPrincipalName -EmailAddresses $proxyAddresses -ErrorAction Stop
        log -message ("Updated proxyAddresses for $UserPrincipalName") -level "INFO"
    }

    Function AzureADGuest-Replace-HiddenFromAddressListsEnabled {
        log -message ("Updating exo address list via: Set-MailUser -Identity $UserPrincipalName -HiddenFromAddressListsEnabled $ShowInAddressListExo") -level "DEBUG"
        Set-MailUser -Identity $UserPrincipalName -HiddenFromAddressListsEnabled $ShowInAddressListExo -ErrorAction Stop
        log -message ("Updated exo address list for $UserPrincipalName") -level "INFO"
    }

    Function AzureADGuest-Replace-Manager {
        log -message ("Updating AzureAD Manager for $UserPrincipalName to $Manager") -level "DEBUG"
        Set-AzureADUserManager -ObjectID $UserPrincipalName -RefObjectId $Manager -ErrorAction Stop
        log -message ("Updated AzureAD Manager for $UserPrincipalName") -level "INFO"
    }

    Function AzureADGuest-Remove {
        log -message ("Removing AzureAD User Object $DN - Remove-AzureADUser -ObjectId $DN") -level "DEBUG"
        Remove-AzureADUser -ObjectId $DN -ErrorAction Stop
        log -message ("Deleted AzureAD User Object $DN") -level "INFO"
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

    # Connects to Azure AD PowerShell Managment Shell
    Connect-AzureAD -Credential $creds

    # Connect to Exchange Online
    $excoPsSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exoURI -Credential $creds -Authentication "Basic" -AllowRedirection
    Import-PSSession $excoPsSession -AllowClobber
    log -message ("Exchange Online PS Session Imported") -level "INFO"

#endregion

}

PROCESS
{
#region *** Variables and logging ***

    # error return code
    $ErrorName = "success"
    $ErrorDetail = $null

    # get base attributes from export object
    $ID = $_.'[ID]'
    $DN = $_.'[DN]'
    $Identifier = $_.'[Identifier]'
    $ObjectType = $_.'[ObjectType]'
    $ObjectModificationType = $_.'[ObjectModificationType]'
    $attributeChanges = $_.'[ChangedAttributeNames]'

    # log base attributes for debugging
    log -message ("Logging Base Attribute Set") -level "DEBUG"
    log -message ("[ID]: $ID") -level "DEBUG"
    log -message ("[DN]: $DN") -level "DEBUG"
    log -message ("[Identifier]: $Identifier") -level "DEBUG"
    log -message ("[Target Object Type]: $ObjectType") -level "DEBUG"
    log -message ("[Operation Type]: $ObjectModificationType") -level "DEBUG"
    log -message ("[Attribute Changes]: $attributeChanges") -level "DEBUG"

    # get management agent specific attributes
    $AccountEnabled = $_.'AccountEnabled'
    $AgeGroup = $_.'AgeGroup'
    $City = $_.'City'
    $CompanyName = $_.'CompanyName'
    $ConsentProvidedForMinor = $_.'ConsentProvidedForMinor'
    $Country = $_.'Country'
    $Department = $_.'Department'
    $DisplayName = $_.'DisplayName'
    $FacsimileTelephoneNumber = $_.'FacsimileTelephoneNumber'
    $GivenName = $_.'GivenName'
    $JobTitle = $_.'JobTitle'
    $LegalAgeGroupClassification = $_.'LegalAgeGroupClassification'
    $Mail = $_.'Mail'
    $MailNickName = $_.'MailNickName'
    $Manager = $_.'Manager'
    $Mobile = $_.'Mobile'
    $PhysicalDeliveryOfficeName = $_.'PhysicalDeliveryOfficeName'
    $PostalCode = $_.'PostalCode'
    $ProxyAddresses = $_.'ProxyAddresses'
    $ShowInAddressList = $_.'ShowInAddressList'
    $ShowInAddressListExo = $_.'ShowInAddressListExo'
    $State = $_.'State'
    $StreetAddress = $_.'StreetAddress'
    $Surname = $_.'Surname'
    $TelephoneNumber = $_.'TelephoneNumber'
    $UsageLocation = $_.'UsageLocation'
    $UserPrincipalName = $_.'UserPrincipalName'
    $UserType = $_.'UserType'

    # log management agent specific attributes for debugging
    log -message ("Logging MA Specific Attribute Set") -level "DEBUG"
    log -message ("[AccountEnabled]: $AccountEnabled") -level "DEBUG"
    log -message ("[AgeGroup]: $AgeGroup") -level "DEBUG"
    log -message ("[City]: $City") -level "DEBUG"
    log -message ("[CompanyName]: $CompanyName") -level "DEBUG"
    log -message ("[ConsentProvidedForMinor]: $ConsentProvidedForMinor") -level "DEBUG"
    log -message ("[Country]: $Country") -level "DEBUG"
    log -message ("[Department]: $Department") -level "DEBUG"
    log -message ("[DisplayName]: $DisplayName") -level "DEBUG"
    log -message ("[FacsimileTelephoneNumber]: $FacsimileTelephoneNumber") -level "DEBUG"
    log -message ("[GivenName]: $GivenName") -level "DEBUG"
    log -message ("[JobTitle]: $JobTitle") -level "DEBUG"
    log -message ("[Mail]: $Mail") -level "DEBUG"
    log -message ("[MailNickName]: $MailNickName") -level "DEBUG"
    log -message ("[Manager]: $Manager") -level "DEBUG"
    log -message ("[Mobile]: $Mobile") -level "DEBUG"
    log -message ("[PhysicalDeliveryOfficeName]: $PhysicalDeliveryOfficeName") -level "DEBUG"
    log -message ("[PostalCode]: $PostalCode") -level "DEBUG"
    log -message ("[ProxyAddresses]: $ProxyAddresses") -level "DEBUG"
    log -message ("[ShowInAddressList]: $ShowInAddressList") -level "DEBUG"
    log -message ("[ShowInAddressListExo]: $ShowInAddressListExo") -level "DEBUG"
    log -message ("[State]: $State") -level "DEBUG"
    log -message ("[StreetAddress]: $StreetAddress") -level "DEBUG"
    log -message ("[Surname]: $Surname") -level "DEBUG"
    log -message ("[TelephoneNumber]: $TelephoneNumber") -level "DEBUG"
    log -message ("[UsageLocation]: $UsageLocation") -level "DEBUG"
    log -message ("[UserPrincipalName]: $UserPrincipalName") -level "DEBUG"
    log -message ("[UserType]: $UserType") -level "DEBUG"

#endregion

#region *** Export - AzureADGuest ***

    log -message ("Executing $ObjectModificationType on $ObjectType") -level "DEBUG"
    if ($ObjectType -eq "AzureADGuest") {

        # create AzureADGuest invitation
        if ( $ObjectModificationType -eq "Add" ) {
            $error.Clear()
            try {
                AzureADGuest-Add
            }
            catch {
                $ErrorName = "New-AzureADMSInvitation failure"
                $ErrorDetail = $error[0]
            }
        }

        # update AzureADUser object
        if ( $ObjectModificationType -eq "Replace" ) {
            $error.clear()
            try {
                AzureADGuest-Replace-User
            }
            catch {
                $ErrorName = "Set-AzureADUser failure"
                $ErrorDetail = $error[0]
            }

            $error.Clear()
            try {
                # set AzureADGuest proxyAddresses
                if ($attributeChanges -ccontains "ProxyAddresses") {
                    AzureADGuest-Replace-ProxyAddress
                }
            }
            catch {
                $ErrorName = "Set-MailUser (update proxyAddresses) failure"
                $ErrorDetail = $error[0]
            }

            $error.Clear()
            try {
                # set AzureADGuest account's manager
                if ($attributeChanges -ccontains "Manager") {
                    AzureADGuest-Replace-Manager
                }
            }
            catch {
                $ErrorName = "Set-AzureADUserManager failure"
                $ErrorDetail = $error[0]
            }

            

            $error.Clear()
            try {
                # set AzureADGuest EXO ShowInAddressListExo
                if ($attributeChanges -ccontains "ShowInAddressListExo") {
                    AzureADGuest-Replace-HiddenFromAddressListsEnabled
                }
            }
            catch {
                $ErrorName = "Set-MailUser (update hide from address list) failure"
                $ErrorDetail = $error[0]
            }

            # set thumbnail on user object
            <#if ($attributeChanges -ccontains "Manager") {
                Set-AzureADUserThumbnail -ObjectID $UserPrincipalName #toBeCompleted
            }#>

        }

        # delete AzureADUser object
        if ( $ObjectModificationType -eq "Delete" ) {
            $error.clear()
            try {
                AzureADGuest-Remove
            }
            catch {
                $ErrorName = "Remove-AzureDAUser Failure"
                $ErrorDetail = $error[0]
            }
        }
    }

#endregion

#region *** Object exception throwing ***

    if ($ErrorName -ne "success") {
        log -message ("Return Status (final): $ErrorName") -level "ERROR"
        log -message ("Error Detail: $ErrorDetail") -level "ERROR"
    }

    #Return the result to the MA
    $obj = @{}
    $obj.Add("[Identifier]",$Identifier)
    $obj.Add("[ErrorName]",$ErrorName)
    if($ErrorDetail){$obj.Add("[ErrorDetail]",$ErrorDetail)}
    $obj

#endregion
}

END
{
    log -message ("[EXPORT JOB] -- Run Profile Complete") -level "INFO"
}