## Declare parameters
$armTemplate = ".\Templates\clusterDeployment.json"
$armtTemplatePathForIdGenerator = ".\Templates\pParameterGeneration.json"
$currentExecutionPath = "C:\Repos\Scripts\Create-GenericCluster"
$clusterVersion = "6.3.176.9494"

## Fixed parameters
$subscriptionId = "9a78d3dd-42ec-490a-a948-16168c10ea00"
$azureRegion = "westeurope"
$azureRegionOms = "westeurope"
$localCertificatePath = "C:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"
$tempIdGeneratorGroupName = "temp-" + [guid]::NewGuid()


## Set environment
Try {
  Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
  if ($_ -like "*Connect-AzureRmAccount to login*") {
    Login-AzureRmAccount
    Set-AzureRmContext -SubscriptionId $subscriptionId
  }
}
cd $currentExecutionPath

## Generate unique id strings
New-AzureRmResourceGroup $tempIdGeneratorGroupName -Location $azureRegion -Force
$output = New-AzureRmResourceGroupDeployment -ResourceGroupName $tempIdGeneratorGroupName -TemplateFile $armtTemplatePathForIdGenerator
$deploymentName = $output.Outputs.uniqueIdToResourceGroup.Value
Remove-AzureRmResourceGroup $tempIdGeneratorGroupName -Force
$deploymentName = ($deploymentName).TrimStart("0123456789?=/&%¤#`"!_.-")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + ".westeurope.cloudapp.azure.com"
#$serviceFabricClusterWebapplicationReplyUrl = "https://" + $serviceFabricClusterDns + ":19080/Explorer/index.html" # Only for AAD registration

## Deploy Azure Key Vault
New-AzureRmResourceGroup -Name $resourceGroup -Location $azureRegion -Tag @{"alias"="chrpap"} -Force 
New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL
$proxyCertificate = Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $proxyCertificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$proxyCertificate.CertificateThumbprint
$proxyCertificate.SourceVault
$proxyCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("reverseProxyCertificateThumbprint", $proxyCertificate.CertificateThumbprint)
$armParameter.Add("reverseProxyCertificateUrlValue", $proxyCertificate.CertificateURL)

Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $generalPassword -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"