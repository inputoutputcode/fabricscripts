## Declare parameters
$armTemplate = ".\ClusterILBBasicSKU.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\InternalOnlyLoadBalancer"
Set-Location $currentExecutionPath

$deploymentName = "chrpap291607"
$sourceVault = "/subscriptions/7e07ba72-cff7-49e5-9099-9ba281f2fea5/resourceGroups/chrpap291607group/providers/Microsoft.KeyVault/vaults/chrpap291607keyvault"
$certificateURL = "https://chrpap291607keyvault.vault.azure.net:443/secrets/chrpap291607cert/5771c0ac84094292b315ed8b8a1b0b63"
$certificateThumbprint = "706B9520C96F83BEDB3619D1C59F39FA024F2965"

## Fixed parameters
$azureRegion = "westus"
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
