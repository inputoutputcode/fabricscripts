
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS3_2NodeType.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "6.5.676.9590"
$azureRegion = "centralus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap090258"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap090258-group/providers/Microsoft.KeyVault/vaults/chrpap090258-keyvault"
$certificateURL = "https://chrpap090258-keyvault.vault.azure.net/secrets/chrpap090258-cert/d32480d72667408694ce1085a853782e"
$certificateThumbprint = "10E451B0E686C9A48B81D5BF62FE90A7D414548B"

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

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Complete -Force

