
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS3_2NodeTypeRefs.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "6.5.676.9590"
$azureRegion = "centralus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap161451"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap161451-group/providers/Microsoft.KeyVault/vaults/chrpap161451-keyvault"
$certificateURL = "https://chrpap161451-keyvault.vault.azure.net/secrets/chrpap161451-cert/1170f3d3afff43fab7180ef78368c052"
$certificateThumbprint = "922335844238A1FD33CF2565E369AED58F298A0C"

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

