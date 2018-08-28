<#
.SYNOPSIS
PSSchema.sp1 - Granfeldt PSMA Schema for AzureAD user object (schema matched to Get-AzureADUser)
.DESCRIPTION
Schema definition used for the population of the FIM/MIM Synchronization engine with AzureAD users and AzureAD B2B "guest" users.
One attribute per object in the schema must be designated as the "Anchor" which will reference the anchor value within the MIM connectorspace. 
In the case of both the user and guest an ID attribute (relates to the objectID in AzureAD) is assigned as the anchor.
.LINK
http://www.integralis.co.za
https://github.com/puttyq/mim.azureb2b.managementagent
https://github.com/sorengranfeldt/psma
.NOTES
Almero Steyn - almero@iitcon.co.za
#>

# schema definition for AzureAD user object
$obj = New-Object -Type PSCustomObject
$obj | Add-Member -Type NoteProperty -Name "Anchor-ID|String" -Value "08572d0c-e5e6-4b9a-bdf1-576de90aa1d9"
$obj | Add-Member -Type NoteProperty -Name "objectID|String" -Value "08572d0c-e5e6-4b9a-bdf1-576de90aa1d9"
$obj | Add-Member -Type NoteProperty -Name "objectClass|String" -Value "AzureADUser"
$obj | Add-Member -Type NoteProperty -Name "AccountEnabled|Boolean" -Value $true
$obj | Add-Member -Type NoteProperty -Name "AgeGroup|String" -Value "10"
$obj | Add-Member -Type NoteProperty -Name "City|String" -Value "Sydney"
$obj | Add-Member -Type NoteProperty -Name "CompanyName|String" -Value "Company"
$obj | Add-Member -Type NoteProperty -Name "ConsentProvidedForMinor|String" -Value "Company"
$obj | Add-Member -Type NoteProperty -Name "Country|String" -Value "Australia"
$obj | Add-Member -Type NoteProperty -Name "CreationType|String" -Value "Invite"
$obj | Add-Member -Type NoteProperty -Name "Department|String" -Value "IT Services"
$obj | Add-Member -Type NoteProperty -Name "DisplayName|String" -Value "Mary Jay Bligh"
$obj | Add-Member -Type NoteProperty -Name "FacsimileTelephoneNumber|String" -Value "02 1234 5678"
$obj | Add-Member -Type NoteProperty -Name "GivenName|String" -Value "Mary"
$obj | Add-Member -Type NoteProperty -Name "ImmutableId|String" -Value "dbJRmSjG7USE++q42Wk34g=="
$obj | Add-Member -Type NoteProperty -Name "JobTitle|String" -Value "BOSS"
$obj | Add-Member -Type NoteProperty -Name "LegalAgeGroupClassification|String" -Value "10"
$obj | Add-Member -Type NoteProperty -Name "Mail|String" -Value "maryjb@customer.com.au"
$obj | Add-Member -Type NoteProperty -Name "MailNickName|String" -Value "maryjb"
$obj | Add-Member -Type NoteProperty -Name "Mobile|String" -Value "0400 123 456"
$obj | Add-Member -Type NoteProperty -Name "OnPremisesSecurityIdentifier|String" -Value "0x100"
$obj | Add-Member -Type NoteProperty -Name "OtherMails|String[]" -Value ("user@somewherelese.com","user@anothersomewhereelse.com")
$obj | Add-Member -Type NoteProperty -Name "PhysicalDeliveryOfficeName|String" -Value "The Big Building"
$obj | Add-Member -Type NoteProperty -Name "PostalCode|String" -Value "2000"
$obj | Add-Member -Type NoteProperty -Name "ProxyAddresses|String[]" -Value ("smtp:user1@customer.com.au", "smtp:user1@customer.co.nz") 
$obj | Add-Member -Type NoteProperty -Name "ShowInAddressList|Boolean" -Value $true
$obj | Add-Member -Type NoteProperty -Name "State|String" -Value "New South Wales"
$obj | Add-Member -Type NoteProperty -Name "StreetAddress|String" -Value "123 Penny Lane"
$obj | Add-Member -Type NoteProperty -Name "Surname|String" -Value "Bigh"
$obj | Add-Member -Type NoteProperty -Name "TelephoneNumber|String" -Value "02 1234 5678"
$obj | Add-Member -Type NoteProperty -Name "UsageLocation|String" -Value "AU"
$obj | Add-Member -Type NoteProperty -Name "UserPrincipalName|String" -Value "maryjb@customer.com.au"
$obj | Add-Member -Type NoteProperty -Name "UserType|String" -Value "member"
$obj | Add-Member -Type NoteProperty -Name "distinguishedName|String" -Value "CN=Azure User test,DC=islamnkhattaboutlook,DC=onmicrosoft,DC=com"
$obj | Add-Member -Type NoteProperty -Name "Manager|String" -Value "df19e8e6-2ad7-453e-87f5-037f6529ae16"
$obj | Add-Member -Type NoteProperty -Name "ManagerDisplayName|String" -Value "Robert Muller"
$obj | Add-Member -Type NoteProperty -Name "ManagerUserPrincipleName|String" -Value "rmuller@special.com"
$obj | Add-Member -Type NoteProperty -Name "ThumbnailLocation|String" -Value "c:\photos\df19e8e6-2ad7-453e-87f5-037f6529ae16.jpg"
$obj | Add-Member -Type NoteProperty -Name "legacyExchangeDN-X500-Cloud|String" -Value "/o=Company/ou=First Administrative Group/cn=Recipients/cn=xxxx"
$obj

# schema definition for AzureAD guest object
$obj = New-Object -Type PSCustomObject
$obj | Add-Member -Type NoteProperty -Name "Anchor-ID|String" -Value "08572d0c-e5e6-4b9a-bdf1-576de90aa1d9"
$obj | Add-Member -Type NoteProperty -Name "objectID|String" -Value "08572d0c-e5e6-4b9a-bdf1-576de90aa1d9"
$obj | Add-Member -Type NoteProperty -Name "objectClass|String" -Value "AzureADGuest"
$obj | Add-Member -Type NoteProperty -Name "AccountEnabled|Boolean" -Value $true
$obj | Add-Member -Type NoteProperty -Name "AgeGroup|String" -Value "10"
$obj | Add-Member -Type NoteProperty -Name "City|String" -Value "Sydney"
$obj | Add-Member -Type NoteProperty -Name "CompanyName|String" -Value "Company"
$obj | Add-Member -Type NoteProperty -Name "ConsentProvidedForMinor|String" -Value "Company"
$obj | Add-Member -Type NoteProperty -Name "Country|String" -Value "Australia"
$obj | Add-Member -Type NoteProperty -Name "CreationType|String" -Value "Invite"
$obj | Add-Member -Type NoteProperty -Name "Department|String" -Value "IT Services"
$obj | Add-Member -Type NoteProperty -Name "DisplayName|String" -Value "Mary Jay Bligh"
$obj | Add-Member -Type NoteProperty -Name "FacsimileTelephoneNumber|String" -Value "02 1234 5678"
$obj | Add-Member -Type NoteProperty -Name "GivenName|String" -Value "Mary"
$obj | Add-Member -Type NoteProperty -Name "ImmutableId|String" -Value "dbJRmSjG7USE++q42Wk34g=="
$obj | Add-Member -Type NoteProperty -Name "JobTitle|String" -Value "BOSS"
$obj | Add-Member -Type NoteProperty -Name "LegalAgeGroupClassification|String" -Value "10"
$obj | Add-Member -Type NoteProperty -Name "Mail|String" -Value "maryjb@customer.com.au"
$obj | Add-Member -Type NoteProperty -Name "MailNickName|String" -Value "maryjb"
$obj | Add-Member -Type NoteProperty -Name "Mobile|String" -Value "0400 123 456"
$obj | Add-Member -Type NoteProperty -Name "OnPremisesSecurityIdentifier|String" -Value "0x100"
$obj | Add-Member -Type NoteProperty -Name "OtherMails|String[]" -Value ("user@somewherelese.com","user@anothersomewhereelse.com")
$obj | Add-Member -Type NoteProperty -Name "PhysicalDeliveryOfficeName|String" -Value "The Big Building"
$obj | Add-Member -Type NoteProperty -Name "PostalCode|String" -Value "2000"
$obj | Add-Member -Type NoteProperty -Name "ProxyAddresses|String[]" -Value ("smtp:user1@customer.com.au", "smtp:user1@customer.co.nz") 
$obj | Add-Member -Type NoteProperty -Name "ShowInAddressList|Boolean" -Value $true
$obj | Add-Member -Type NoteProperty -Name "ShowInAddressListExo|Boolean" -Value $true
$obj | Add-Member -Type NoteProperty -Name "State|String" -Value "New South Wales"
$obj | Add-Member -Type NoteProperty -Name "StreetAddress|String" -Value "123 Penny Lane"
$obj | Add-Member -Type NoteProperty -Name "Surname|String" -Value "Bigh"
$obj | Add-Member -Type NoteProperty -Name "TelephoneNumber|String" -Value "02 1234 5678"
$obj | Add-Member -Type NoteProperty -Name "UsageLocation|String" -Value "AU"
$obj | Add-Member -Type NoteProperty -Name "UserPrincipalName|String" -Value "maryjb@customer.com.au"
$obj | Add-Member -Type NoteProperty -Name "UserType|String" -Value "member"
$obj | Add-Member -Type NoteProperty -Name "distinguishedName|String" -Value "CN=Azure User test,DC=islamnkhattaboutlook,DC=onmicrosoft,DC=com"
$obj | Add-Member -Type NoteProperty -Name "Manager|String" -Value "df19e8e6-2ad7-453e-87f5-037f6529ae16"
$obj | Add-Member -Type NoteProperty -Name "ManagerDisplayName|String" -Value "Robert Muller"
$obj | Add-Member -Type NoteProperty -Name "ManagerUserPrincipleName|String" -Value "rmuller@special.com"
$obj | Add-Member -Type NoteProperty -Name "ThumbnailLocation|String" -Value "c:\photos\df19e8e6-2ad7-453e-87f5-037f6529ae16.jpg"
$obj | Add-Member -Type NoteProperty -Name "legacyExchangeDN-X500-Cloud|String" -Value "/o=Company/ou=First Administrative Group/cn=Recipients/cn=xxxx"
$obj