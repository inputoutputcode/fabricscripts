## Declare parameters
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster_VMSS1_Vanilla_LogAnalytics.json" # 
$currentExecutionPath = "C:\Code\fabricscripts\GenericCluster"
$signinName = "Christian@poststev.onmicrosoft.com"
$azureRegion = "westus2"
$localCertificatePath = "C:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"


$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId 


cd $currentExecutionPath
$deploymentName = "chrpap122229" #+ (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
$omsName = $deploymentName + "-oms"

#$clusterCertificate.CertificateThumbprint
#$clusterCertificate.SourceVault
#$clusterCertificate.CertificateURL


$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterDNSname", $serviceFabricClusterDns)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("omsWorkspaceName", $omsName)
#$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
#$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
#$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("sourceVaultValue", "https://chrpap122229-keyvault.vault.azure.net/")
$armParameter.Add("CertificateUrlValue", "https://chrpap122229-keyvault.vault.azure.net/secrets/chrpap122229-cert/43a028d7972d4515aa4f513e345379c2")
$armParameter.Add("CertificateThumbprint", "762F519196A25B1CD23841108BBE5AF372880E88")

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

