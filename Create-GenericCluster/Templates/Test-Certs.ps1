
# https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps
New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName stev.de
#6DE62263BE7C2795FD2F19B289CBF941576A4EB4  CN=stev.de
$cert = Get-ChildItem -Path Cert:\CurrentUser\My\6DE62263BE7C2795FD2F19B289CBF941576A4EB4


New-SelfSignedCertificate -NotBefore '2020-05-05' -NotAfter '2021-05-05' -DnsName www.servicefabriccluster1.eastus.cloudapp.azure.com -CertStoreLocation Cert:\CurrentUser\My -Provider "Microsoft Strong Cryptographic Provider" -KeyExportPolicy ExportableEncrypted
#125C938B35F9359C02A25A6212540B25F0EBD20C  CN=www.domain-name.eastus.cloudapp.azure.com
$cert = Get-ChildItem -Path Cert:\CurrentUser\My\AA7910B20A8DDE00666C9A18E783F3956EEA9B2C


New-SelfSignedCertificate -NotBefore '2020-05-05' -NotAfter '2021-05-05' -DnsName 'www.servicefabriccluster2.eastus.cloudapp.azure.com' -CertStoreLocation Cert:\CurrentUser\My -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy ExportableEncrypted #-Subject "<Enter Subject>"
#FC21592E53B291F399380E83055595824A2CC858  CN=www.domain-name2.eastus.cloudapp.azure.co
$cert = Get-ChildItem -Path Cert:\CurrentUser\My\FC21592E53B291F399380E83055595824A2CC858


