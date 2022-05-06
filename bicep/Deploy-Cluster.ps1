
## Parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
$templateFileName = "SimpleFiveNode.bicep"
$azureRegion = "westus"
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")
$generalPassword = ConvertTo-SecureString "nZ549Ux2MnW6srTvOZsq" -AsPlainText -Force
$currentExecutionPath = "C:\Code\FabricScripts\bicep"
$localCertificatePath = "C:\Certificates\"
$certificateName = $deploymentName + "-cert"
$resourceGroupName = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
cd $currentExecutionPath
Enable-AzureRmAlias

# Admin check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Script must be executed as Administrator." -ForegroundColor Red -BackgroundColor Yellow
    Exit;
}

## Login to Azure
Try {
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
  } Catch {
      Login-AzAccount
      Set-AzContext -SubscriptionId $subscriptionId
  }

## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroupName -Location $azureRegion -Force
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true" 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $azureRegion -EnabledForDeployment 
Import-Module ".\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFileName -deploymentId $deploymentName -certificateThumbprint $clusterCertificate.CertificateThumbprint -sourceVaultValue $clusterCertificate.SourceVault -certificateUrlValue $clusterCertificate.CertificateURL -adminPassword $generalPassword -Verbose -Mode Incremental


$templateFileNameAppUpdate = "UpdateFabricObserver.bicep"
New-AzResourceGroupDeployment -Name fabricObserverUpgrade -ResourceGroupName $resourceGroupName -TemplateFile $templateFileNameAppUpdate -deploymentId $deploymentName -Verbose -Mode Incremental
