# Microsoft AzureAD B2B Guest Synchronization Management Agent for MIM
A Granfeldt PowerShell management agent for FIM/MIM

This project provides a complete MIM implementation of the [Granfeldt PSMA](https://github.com/sorengranfeldt/psma) to facilitate Microsoft Azure Active Directory (AzureAD) intergraton, perticularly for the purpose of enabling Microsoft Azure B2B (Azure B2B) synchronization between tenants taht requires the users to show up in the Exchange GAL. The management agent was born out of the need to establish Azure B2B guest provisioning to multiple forests which also included the usage of Azure B2B guest accounts within the Microsoft Exchange Online GAL (Global Address List).

Options to accomplish this includes using the Microsoft Azure Graph API Management Agent (preview at the time of writing this document), but this had some limitations. Examples included:
* limited support for the complete AzureADUser attribute set (e.g. proxyAddresses)
* restrictions on the ability to write to certain attributes (e.g. proxyAddresses)
* flexibility in creating a solution using one management agent (since other options needed to be added to create a complete solution)

Due to these reasons the choice was made to persue a complete PowerShell-based implementation using the Granfeldt [Granfeldt PSMA](https://github.com/sorengranfeldt/psma) due to great flexibility and a stable interface with MIM.

## Azure Active Directory Attribute Supported

The following attribute can be imported using the management agent. 

| Attribute                    | DataType | Import                   | Export                 |
|------------------------------|----------|--------------------------|------------------------|
| AccountEnabled               | Boolean  | Get-AzureADUser          | Set-AzureADUser        |
| AgeGroup                     | String   | Get-AzureADUser          | Set-AzureADUser        |
| City                         | String   | Get-AzureADUser          | Set-AzureADUser        |
| CompanyName                  | String   | Get-AzureADUser          |                        |
| ConsentProvidedForMinor      | String   | Get-AzureADUser          | Set-AzureADUser        |
| Country                      | String   | Get-AzureADUser          | Set-AzureADUser        |
| CreationType                 | String   | Get-AzureADUser          |                        |
| Department                   | String   | Get-AzureADUser          | Set-AzureADUser        |
| DisplayName                  | String   | Get-AzureADUser          | Set-AzureADUser        |
| FacsimileTelephoneNumber     | String   | Get-AzureADUser          | Set-AzureADUser        |
| GivenName                    | String   | Get-AzureADUser          | Set-AzureADUser        |
| ImmutableId                  | String   | Get-AzureADUser          |                        |
| JobTitle                     | String   | Get-AzureADUser          | Set-AzureADUser        |
| LegalAgeGroupClassification  | String   | Get-AzureADUser          | Set-AzureADUser        |
| Mail                         | String   | Get-AzureADUser          |                        |
| Mobile                       | String   | Get-AzureADUser          | Set-AzureADUser        |
| OnPremisesSecurityIdentifier | String   | Get-AzureADUser          |                        |
| OtherMails                   | String() | Get-AzureADUser          |                        |
| PhysicalDeliveryOfficeName   | String   | Get-AzureADUser          | Set-AzureADUser        |
| PostalCode                   | String   | Get-AzureADUser          | Set-AzureADUser        |
| ProxyAddresses               | String() | Get-AzureADUser          | Set-MailUser           |
| ShowInAddressList            | Boolean  | Get-AzureADUser          | Set-AzureADUser        |
| ShowInAddressListExo         | Boolean  | Get-MailUser             | Set-MailUser           |
| State                        | String   | Get-AzureADUser          | Set-AzureADUser        |
| StreetAddress                | String   | Get-AzureADUser          | Set-AzureADUser        |
| Surname                      | String   | Get-AzureADUser          | Set-AzureADUser        |
| TelephoneNumber              | String   | Get-AzureADUser          | Set-AzureADUser        |
| UsageLocation                | String   | Get-AzureADUser          | Set-AzureADUser        |
| UserPrincipalName            | String   | Get-AzureADUser          | Set-AzureADUser        |
| UserType                     | String   | Get-AzureADUser          |                        |
| distinguishedName            | String   | Get-AzureADUser          |                        |
| Manager                      | String   | Get-AzureADUserManager   | Set-AzureADUserManager |
| ManagerDisplayName           | String   | Get-AzureADUserManager   |                        |
| ManagerUserPrincipleName     | String   | Get-AzureADUserManager   |                        |
| ThumbnailLocation            | String   | Get-AzureADUserThumbnail |                        |


# Known Issues

At present there are certain limitations of the management agent. These includes:
* only full imports are supported
* the "otherMails" attribute is currently not implemented
* user thumbnail images are currently not working


# Known Limitations

* **Delta Imports:** The Azure.B2B.PSMA users the AzureAD PowerShell Module and the Exchange PowerShell provider to read and write to Azure AD B2B guest users. As a result the MA does not support delta import operations since there is not a way to only filter changes in the PowerShell module. Even thought there is no delta import support, full imports does not take very long (production tenant with 17k users takes about 4 minutes). If however you enable additional metadata imports (via the import filters in the XML file) such as Manager the import requires a second PowerShell execution for every object (to get the Get-AzureADUserManager result). In this case the import time increases from 4 minutes to around 40 minutes.
* **Manual Config:** One of the key challanges with creating the MIM configuration to support the management agent is the static nature of management agent configuration. At present new management agents and specific parameters needs to be manually added (which includes key management agent configuration settings and metaverse extension development) each time a new sync partner is added. Some of this will remain since the objective is never to make it completely dynamic, but there is however a desire to remove some of the manual settings since these could create confusion during deployment and operational support.


# Contributing

Contributing to this project is welcomed and encouraged since I believe the community can benefit from keeping this updated. When contributing to this repository, please first discuss the change you wish to make via the creation of an issue or sending an email.
