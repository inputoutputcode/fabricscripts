
##F38CD9768351364AEA620EBEDE5C0A1676FD21C3
##/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpap241522-group/providers/Microsoft.KeyVault/vaults/chrpap241522-keyvault
##https://chrpap241522-keyvault.vault.azure.net:443/secrets/chrpap241522-new-cert/139f6cb2ffc84a49b622c8416c6bad83

$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS1_Vanilla_NetIso.json" # 
$currentExecutionPath = "D:\Code\inputoutputcode\fabricscripts\GenericCluster"

$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$clusterVersion = "8.2.1486.9590"
$azureRegion = "eastus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$deploymentName = "chrpap210947"

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

$sourceVault = "/subscriptions/d715466f-2653-406f-be2f-495f7fd4e1b7/resourceGroups/chrpap210947-group/providers/Microsoft.KeyVault/vaults/chrpap210947-keyvault"
$certificateURL = "https://chrpap210947-keyvault.vault.azure.net:443/secrets/chrpap210947-cert/47db6f0949374ee8864ad5357ba9111f"
$certificateThumbprint = "883E73743E47C38A930D84453AB76F482D5CEFE9"


## Deploy Azure Service Fabric Cluster
$armParameter = @{}
#$armParameter.Add("secCertificateThumbprint", "740CEE5FEAEBBC6CED25423E05B7536FE1F28F55")
#$armParameter.Add("secCertificateUrlValue", "https://chrpap251352-keyvault.vault.azure.net/secrets/chrpap251352-new-cert/53c8eebfc21d48de90ae3813c80dd0d4")
#$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("clusterDNSname", $serviceFabricClusterDns)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $sourceVault)
$armParameter.Add("certificateUrlValue", $certificateURL)
$armParameter.Add("certificateThumbprint", $certificateThumbprint)



Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -Name "SwapCertsOnCluster" -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental -Force

