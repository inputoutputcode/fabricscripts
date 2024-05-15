## Declare parameters
$armTemplate = ".\101-managed-service-fabric-cluster-standard-2-nt\azuredeploy.json"
$armParameters = ".\101-managed-service-fabric-cluster-standard-2-nt\azuredeploy.parameters.json"
$currentExecutionPath = "C:\Code\FabricScripts\ManagedCluster"

## Fixed parameters
$azureRegion = "eastus2"
$localCertificatePath = "C:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

## Set Corp sub
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
## OR
## Set MSDN sub
$subscriptionId = "d715466f-2653-406f-be2f-495f7fd4e1b7" 
$tenant = "7459bed2-8ead-4b9b-84ff-38402c19a97d"
Connect-AzAccount -Tenant $tenant -SubscriptionId $subscriptionId 

cd $currentExecutionPath
Enable-AzureRmAlias

## Generate unique id strings
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-msf"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module "..\GenericCluster\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("clientCertificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("clusterSku", "Standard")
$armParameter.Add("adminUserName", "Christian")
$armParameter.Add("nodeType1Name", "nt1")
$armParameter.Add("nodeType1VmSize", "Standard_D2_v2")
$armParameter.Add("nodeType1VmInstanceCount", 5)
$armParameter.Add("nodeType1DataDiskSizeGB", 120)

$armParameter.Add("nodeType2Name", "nt2")
$armParameter.Add("nodeType2VmSize", "Standard_D2_v2")
$armParameter.Add("nodeType2VmInstanceCount", 3)
$armParameter.Add("nodeType2DataDiskSizeGB", 120)

$armParameter.Add("vmImagePublisher", "MicrosoftWindowsServer")
$armParameter.Add("vmImageOffer", "WindowsServer")
$armParameter.Add("vmImageSku", "2019-Datacenter")
$armParameter.Add("vmImageVersion", "latest")

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