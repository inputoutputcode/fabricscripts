
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS1.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "6.5.676.9590"
$azureRegion = "centralus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap021121"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap021121-group/providers/Microsoft.KeyVault/vaults/chrpap021121-keyvault"
$certificateURL = "https://chrpap021121-keyvault.vault.azure.net/secrets/chrpap021121-cert/7f452c1cc4f04ce5b4f535aa21cfedba"
$certificateThumbprint = "BF71968B52098A7873B607C49354B3D4CB53C69A"

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $sourceVault)
$armParameter.Add("certificateUrlValue", $certificateURL)
$armParameter.Add("certificateThumbprint", $certificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

