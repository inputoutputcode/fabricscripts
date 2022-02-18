## Declare parameters
$armTemplate = ".\Templates\5-VM-Windows-1-NodeTypes-Secure-NSG.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$clusterVersion = "6.5.676.9590"

## Fixed parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$azureRegion = "eastus"
$localCertificatePath = "D:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

## Set environment
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
cd $currentExecutionPath
Enable-AzureRmAlias

## Generate unique id strings
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
#$serviceFabricClusterWebapplicationReplyUrl = "https://" + $serviceFabricClusterDns + ":19080/Explorer/index.html" # Only for AAD registration

## Deploy Azure Key Vault
New-AzTag -Name "alias"
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Tag @{"alias"="chrpap"} -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("clusterLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminUserName", $generalPassword)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Complete -Force

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $generalPassword -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"