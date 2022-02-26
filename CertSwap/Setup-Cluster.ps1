## Declare parameters
$armTemplate = ".\Cluster_VMSS1.json" 
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\CertSwap"
$clusterVersion = "8.2.1486.9590"

## COPR subscription
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
# Set environment 
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

# MSDN (Disconnect-AzAccount, Connect-AzAccount with christian@poststev.onmicrosoft.com)
<#
$subscriptionId = "d715466f-2653-406f-be2f-495f7fd4e1b7"
$tenantId = "7459bed2-8ead-4b9b-84ff-38402c19a97d"
Disconnect-AzAccount
Login-AzAccount -Tenant $tenantId
Connect-AzAccount -Tenant $tenantId
Select-AzSubscription -SubscriptionId $subscriptionId -Tenant $tenantId -ErrorAction Stop
Set-AzContext -SubscriptionId $subscriptionId
#>

$azureRegion = "eastus"
$localCertificatePath = "D:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

cd $currentExecutionPath
Enable-AzureRmAlias

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Script must be executed as Administrator." -ForegroundColor Red -BackgroundColor Yellow
    Exit;
}

## Generate unique id strings
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
$omsName = $deploymentName + "-oms"

## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true" 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment 
Import-Module ".\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Create secondary cert
$secondaryCertificateName = $deploymentName + "-new-cert"
$secondaryClusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $secondaryCertificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$secondaryClusterCertificate.CertificateThumbprint
$secondaryClusterCertificate.SourceVault
$secondaryClusterCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterDNSname", $serviceFabricClusterDns)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("secondaryCertificateUrlValue", $secondaryClusterCertificate.CertificateURL)
$armParameter.Add("secondaryCertificateThumbprint", $secondaryClusterCertificate.CertificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental
