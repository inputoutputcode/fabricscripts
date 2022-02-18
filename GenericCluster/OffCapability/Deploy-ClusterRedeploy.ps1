## Declare parameters
$armTemplate = ".\Cluster-ExternalRoot-StoragePolicy.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\OffCapability"

## Fixed parameters
$subscriptionId = "7e07ba72-cff7-49e5-9099-9ba281f2fea5"
$azureRegion = "eastus"
$localCertificatePath = "D:\Certificates\"
$machineAdminUser = "Christian"
$machineAdminPass = "nZ549Ux2MnW6srTvOZsq"
$clusterVersion = "7.1.409.9590"

## Set environment
cd $currentExecutionPath

## Generate unique id strings
$deploymentName = "chrpap221715"

# Define dynamic parameters
$certificateName = $deploymentName + "cert"
$resourceGroup = $deploymentName + "group"
$fileShareStorageName = $deploymentName + "fileshare"
$scriptStorageName = $deploymentName + "script"
$keyVaultName = $deploymentName + "keyvault"
$serviceFabricClusterName = $deploymentName + "servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", "chrpap221715servicefabric")
$armParameter.Add("adminPassword", $machineAdminPass)
$armParameter.Add("sourceVaultValue", "/subscriptions/7e07ba72-cff7-49e5-9099-9ba281f2fea5/resourceGroups/chrpap221715group/providers/Microsoft.KeyVault/vaults/chrpap221715keyvault")
$armParameter.Add("certificateUrlValue", "https://chrpap221715keyvault.vault.azure.net:443/secrets/chrpap221715cert/6d735ebd9cc84b0d9b3d102404f2ffae")
$armParameter.Add("certificateThumbprint", "3E2B21BD40060E15507A7D0DE1EF6300264F2F62")
$armParameter.Add("extensionMountScriptFileUri", "https://chrpap221715script.blob.core.windows.net/extensionscripts/Mount-ManagedDisk.ps1")

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

