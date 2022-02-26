
##F38CD9768351364AEA620EBEDE5C0A1676FD21C3
##/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap241522-group/providers/Microsoft.KeyVault/vaults/chrpap241522-keyvault
##https://chrpap241522-keyvault.vault.azure.net:443/secrets/chrpap241522-new-cert/139f6cb2ffc84a49b622c8416c6bad83

$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS1-UpdateCert.json" # 
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\GenericCluster"
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "8.2.1486.9590"
$azureRegion = "eastus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap251352"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap251352-group/providers/Microsoft.KeyVault/vaults/chrpap251352-keyvault"
$certificateURL = "https://chrpap251352-keyvault.vault.azure.net/secrets/chrpap251352-cert/8213dd32b51a4b359d6ccbb207a5d4e0"
$certificateThumbprint = "3AD98C14A1C09C496E8B14B74C5595DA45A3CA72"

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("secCertificateThumbprint", "740CEE5FEAEBBC6CED25423E05B7536FE1F28F55")
$armParameter.Add("secCertificateUrlValue", "https://chrpap251352-keyvault.vault.azure.net/secrets/chrpap251352-new-cert/53c8eebfc21d48de90ae3813c80dd0d4")
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("clusterDNSname", $serviceFabricClusterDns)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $sourceVault)
$armParameter.Add("certificateUrlValue", $certificateURL)
$armParameter.Add("certificateThumbprint", $certificateThumbprint)



Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -Name "SwapCertsOnCluster" -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental -Force

