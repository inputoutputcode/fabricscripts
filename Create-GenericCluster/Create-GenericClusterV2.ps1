## Declare parameters
$armTemplate = ".\noderemovalportaltemplate\template_1vmss.json"
$currentExecutionPath = "D:\Code\inputoutputcode\FabricMonkey\Create-GenericCluster"
$clusterVersion = "6.5.676.9590"

## Fixed parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$azureRegion = "centralus"
$localCertificatePath = "D:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

## Set environment
Try {
  $subscription = Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
cd $currentExecutionPath
Enable-AzureRmAlias

## Generate unique id strings
$deploymentName = "chrpap" + (Get-Date).ToString("ddhhmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

## Deploy Azure Key Vault
Write-Host "Creating tags"
$tag = New-AzTag -Name "alias"
Write-Host "Creating group"
$group = New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Tag @{"alias"="chrpap"} -Force 
Write-Host "Creating KeyVault"
$keyVault = New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1" -Force
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
Write-Host "Creating certificate"
$clusterCertificate = Invoke-AddCertToKeyVaultAsCert -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("keyVaultResourceId", $keyVault.ResourceId)

Write-Host "Testing ARM template"
Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

Write-Host "Start ARM deployment"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $generalPassword -AsPlainText -Force
Write-Host "Importing certificate locally"
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"