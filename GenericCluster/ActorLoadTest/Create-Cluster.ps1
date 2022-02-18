## Declare parameters
$armTemplate = ".\SixNodeD2.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\ActorLoadTest"

## Fixed parameters
$subscriptionId = "7e07ba72-cff7-49e5-9099-9ba281f2fea5" 
# MSDN 7e07ba72-cff7-49e5-9099-9ba281f2fea5
# SF 13ad2c84-84fa-4798-ad71-e70c07af873f
$azureRegion = "eastus"
$localCertificatePath = "D:\Certificates\"
$machineAdminUser = "Christian"
$machineAdminPass = "nZ549Ux2MnW6srTvOZsq"
$clusterVersion = "8.0.514.9590"

## Set environment
cd $currentExecutionPath

## Generate unique id strings
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "cert"
$resourceGroup = $deploymentName + "group"
$fileShareStorageName = $deploymentName + "fileshare"
$scriptStorageName = $deploymentName + "script"
$keyVaultName = $deploymentName + "keyvault"
$serviceFabricClusterName = $deploymentName + "servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\..\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $machineAdminPass
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterLocation", $azureRegion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("dnsName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $machineAdminPass)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("clientCertificateThumbprint", $clusterCertificate.CertificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose


## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $machineAdminPass -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword
