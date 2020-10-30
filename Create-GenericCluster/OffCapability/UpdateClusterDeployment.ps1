$armTemplate = ".\Cluster-ExternalRootTLSIssue.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\OffCapability"
$clusterVersion = "7.1.417.9590"
$azureRegion = "westus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

Set-Location $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap241543"

# Define dynamic parameters
$resourceGroup = $deploymentName + "group"
$serviceFabricClusterName = $deploymentName + "servicefabric"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap241543group/providers/Microsoft.KeyVault/vaults/chrpap241543keyvault"
$certificateURL = "https://chrpap241543keyvault.vault.azure.net/secrets/chrpap241543cert/d8f7a0593b084abfa0a306b6dc5aa9cc"
$certificateThumbprint = "2B235454D2A4B5979EF87E4CC0256A60119E287D"

$extensionMountScriptFileUri = "https://chrpap241543script.blob.core.windows.net/extensionscripts/Mount-ManagedDisk.ps1"

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
$armParameter.Add("extensionMountScriptFileUri", $extensionMountScriptFileUri)


Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Complete -Force

