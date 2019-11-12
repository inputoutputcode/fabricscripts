## Declare parameters
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster.json"
$armtTemplatePathForIdGenerator = ".\Templates\Vortex-LoadTest-ParameterGeneration.json"
$currentExecutionPath = "D:\Code\Azure%20Service%20Fabric%20Skripts\Create-GenericCluster"
$clusterVersion = "6.5.676.9590"

## Fixed parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$azureRegion = "centralus"
$azureRegionOms = "centralus"
$localCertificatePath = "D:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"
$tempIdGeneratorGroupName = "temp-" + [guid]::NewGuid()


## Set environment
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
cd $currentExecutionPath

## Generate unique id strings
New-AzResourceGroup $tempIdGeneratorGroupName -Location $azureRegion -Force
$output = New-AzResourceGroupDeployment -ResourceGroupName $tempIdGeneratorGroupName -TemplateFile $armtTemplatePathForIdGenerator
$deploymentName = $output.Outputs.uniqueIdToResourceGroup.Value
Remove-AzResourceGroup $tempIdGeneratorGroupName -Force
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
New-AzTag -Name "alias"
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Tag @{"alias"="chrpap"} -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
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

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $generalPassword -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"