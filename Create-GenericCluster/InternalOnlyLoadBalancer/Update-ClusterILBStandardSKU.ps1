## Declare parameters
$armTemplate = ".\ClusterILBStandardSKU.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\InternalOnlyLoadBalancer"
Set-Location $currentExecutionPath

$deploymentName = "chrpap291657"
$sourceVault = "/subscriptions/7e07ba72-cff7-49e5-9099-9ba281f2fea5/resourceGroups/chrpap291657group/providers/Microsoft.KeyVault/vaults/chrpap291657keyvault"
$certificateURL = "https://chrpap291657keyvault.vault.azure.net:443/secrets/chrpap291657cert/4de59af467044a5cb71009fc6b80260d"
$certificateThumbprint = "251D008E576C20D5A6A6C4796CEBEF83B008A39E"

## Fixed parameters
$azureRegion = "eastus"
$machineAdminPass = "nZ549Ux2MnW6srTvOZsq"
$clusterVersion = "7.2.413.9590"
$resourceGroup = $deploymentName + "group"
$serviceFabricClusterName = $deploymentName + "servicefabric"

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $machineAdminPass)
$armParameter.Add("sourceVaultValue", $sourceVault)
$armParameter.Add("certificateUrlValue", $certificateURL)
$armParameter.Add("certificateThumbprint", $certificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Complete