# Microsoft AzureAD B2B Guest Synchronization Management Agent for MIM
A Granfeldt PowerShell management agent for FIM/MIM

The following project provides a complete implementation of the [Granfeldt PSMA](https://github.com/sorengranfeldt/psma) in order to facilitate Microsoft Azure Active Directory (AzureAD) intergraton, perticularly for the purpose of enabling Microsoft Azure B2B (Azure B2B) synchronization between tenants. The management agent was born out of the need to establish Azure B2B guest provisioning to multiple forests which also included the usage of Azure B2B guest accounts within the Microsoft Exchange Online GAL (Global Address List).

Options to accomplish this includes using the Microsoft Azure Graph API Management Agent (preview at the time of writing this document), but this had some pronounced limitations. Examples included:
* limited support for the complete AzureADUser attribute set (e.g. proxyAddresses)
* restrictions on the ability to write to certain attributes
* flexibility in creating a solution using one management agent (since other options needed to be added to create a complete solution)

Due to these reasons the choice was made to persue a complete PowerShell-based implementation using the Granfeldt [Granfeldt PSMA](https://github.com/sorengranfeldt/psma) due to great flexibility and a stable interface with MIM.


## Azure Active Directory Attribute Supported

The following attribute can be imported using the management agent. 
* Any attribute in **bold** is also exportable.
* Attributes is *italics* are just imported informationally (not exportable)

| Attributes         | Attributes                  | Attributes          | Attributes         |
|--------------------------|------------------------------|-------------------|--------------------------|
| **AccountEnabled**           | **GivenName**                    | **ProxyAddresses**    | **Manager**                  |
| **AgeGroup**                 | *ImmutableId*                  | **ShowInAddressList** | *ManagerDisplayName*       |
| **City**                     | **JobTitle**                     | **State**             | *ManagerUserPrincipleName* |
| *CompanyName*              | *LegalAgeGroupClassification*  | **StreetAddress**     | ThumbnailLocation        |
| **ConsentProvidedForMinor**  | **Mail**                         | **Surname**           |                          |
| **Country**                  | **Mobile**                       | **TelephoneNumber**   |                          |
| *CreationType*             | *OnPremisesSecurityIdentifier* | **UsageLocation**     |                          |
| **Department**               | **OtherMails**                   | **UserPrincipalName** |                          |
| **DisplayName**              | **PhysicalDeliveryOfficeName**   | *UserType*          |                          |
| **FacsimileTelephoneNumber** | **PostalCode**                   | *distinguishedName* |                          |


# Known Issues

At present there are certain limitations of the management agent. These includes:
* only full imports are supported
* the "otherMails" attribute is currently not implemented
* user thumbnail images are currently not working


# Known Limitations

One of the key challanges with creating the MIM configuration to support the management agent is the static nature of management agent configuration. At present new management agents and specific parameters needs to be manually added (which includes key management agent configuration settings and metaverse extension development) each time a new sync partner is added. Some of this will remain since the objective is never to make it completely dynamic, but there is however a desire to remove some of the manual settings since these could create confusion during deployment and operational support.


# Contributing

Contributing to this project is welcomed and encouraged since I believe the community can benefit from keeping this updated. When contributing to this repository, please first discuss the change you wish to make via the creation of an issue or sending an email.
