
$armTemplate = ".\Templates\patch-orchestration-application.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "8.2.1235.9590"
$azureRegion = "westus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap071116"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap071116-group/providers/Microsoft.KeyVault/vaults/chrpap071116-keyvault"
$certificateURL = "https://chrpap071116-keyvault.vault.azure.net/secrets/chrpap071116-cert/95a82b262e0045478257444edde2beec"
$certificateThumbprint = "ECCB3B18883A166AA7B40D93A6B2FEBC737883C6"

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

