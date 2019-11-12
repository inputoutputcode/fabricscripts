################################################
## Parameters
################################################
$resourceGroupNameServiceFabric = "chrpap-sf-mcd-rsx"
$resourceGroupNameKeyVault = "chrpap-kv-mcd-rsx"
$keyVaultName = "chrpap-kv-mcd"
$region = "germanycentral"
$privateKeyFilePath = "C:\Certificates\Something.pfx"
$privateKeyPath = "C:\Certificates\"
$primaryCertName = "chrpap-sf-mcd"

$clusterDnsName = "chrpap-sf.germanycentral.azurecloudapp.de"
$clusterName = "chrpap-sfcluster"
$webapplicationReplyUrl = 'https://chrpap-sf.germanycentral.azurecloudapp.de:19080/Explorer/index.html'
$subscriptionId = '7ae72bdf-b855-4f3d-914e-3472967b671c' 

$certificatePassword = Read-Host "Please enter the password for the certificate." -AsSecureString

# AAD tenant id from the portal
$tenantId = 'f1c9b125-e2bf-48c0-b025-23e47c410293'

################################################
## No Touch
################################################
Login-AzureRmAccount -Environment AzureGermanCloud
Set-AzureRmContext -SubscriptionId $subscriptionId

New-AzureRmResourceGroup -Name $resourceGroupNameServiceFabric -Location $region
New-AzureRmResourceGroup -Name $resourceGroupNameKeyVault -Location $region

Register-AzureRmResourceProvider -ProviderNamespace Microsoft.KeyVault
New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupNameKeyVault -Location $region -EnabledForDeployment -Sku Premium

Import-Module "C:\Code\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupNameKeyVault -Location $region -VaultName $keyVaultName -CertificateName $primaryCertName -CreateSelfSignedCertificate -DnsName $clusterDnsName -OutputPath $privateKeyPath -Password $certificatePassword

<#
Name  : CertificateThumbprint
Value : D41D8DE3A15672AEA428046268014D913B160350

Name  : SourceVault
Value : /subscriptions/7ae72bdf-b855-4f3d-914e-3472967b671c/resourceGroups/chrpap-kv-mcd-rsx/providers/Microsoft.KeyVault/vaults/chrpap-kv-mcd

Name  : CertificateURL
Value : https://chrpap-kv-mcd.vault.microsoftazure.de:443/secrets/chrpap-sf-mcd/8b437758035d43cf92c00e8ebbcc6d89
#>

# The german cloud has different endpoints
# Get-AzureEnvironment -Name AzureGermanCloud

C:\Code\MicrosoftAzureServiceFabric-AADHelpers> .\SetupApplications.ps1 -TenantId $tenantId -ClusterName $clusterName -WebApplicationReplyUrl $webapplicationReplyUrl -Location "german"
<#
TenantId                       f1c9b125-e2bf-48c0-b025-23e47c410293                                                                                                                                                                                              
WebAppId                       9e776163-2766-4ea7-ae77-c74653b5e9b5                                                                                                                                                                                              
NativeClientAppId              248ccd52-abb1-403e-a53a-86711e151f31                                                                                                                                                                                              
ServicePrincipalId             2b84b565-f530-4143-a075-c2dbb291cfc2                                                                                                                                                                                              

-----ARM template-----
"azureActiveDirectory": {
  "tenantId":"f1c9b125-e2bf-48c0-b025-23e47c410293",
  "clusterApplication":"9e776163-2766-4ea7-ae77-c74653b5e9b5",
  "clientApplication":"248ccd52-abb1-403e-a53a-86711e151f31"
},
#>

Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupNameServiceFabric -TemplateFile .\azuredeploy-mcd.json -TemplateParameterFile .\azuredeploy-mcd.parameters.json
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupNameServiceFabric -TemplateFile .\azuredeploy-mcd.json -TemplateParameterFile .\azuredeploy-mcd.parameters.json


# Setup for the certificates on your local box
$certificateFile = $privateKeyPath + $primaryCertName + ".pfx"
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword

# The TrustedPeople store is only needed for self-signed certificates
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

$certificateThumbprint= "D41D8DE3A15672AEA428046268014D913B160350"
$clusterEndpoint = "chrpap-servicefabric.germanycentral.cloudapp.microsoftazure.de:19000"
Connect-ServiceFabricCluster -ConnectionEndpoint $clusterEndpoint -KeepAliveIntervalInSec 10 `
    -X509Credential `
    -ServerCertThumbprint $certificateThumbprint  `
    -FindType FindByThumbprint `
    -FindValue $certificateThumbprint `
    -StoreLocation CurrentUser `
    -StoreName My

Get-ServiceFabricClusterHealth

Remove-AzureRmResourceGroup -Name $resourceGroupNameServiceFabricPrimary