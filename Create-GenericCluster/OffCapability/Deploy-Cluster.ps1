## Declare parameters
$armTemplate = ".\Cluster-ExternalRoot.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\OffCapability"

## Fixed parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$azureRegion = "westus"
$localCertificatePath = "D:\Certificates\"
$machineAdminUser = "Christian"
$machineAdminPass = "nZ549Ux2MnW6srTvOZsq"

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
$certificateName = $deploymentName + "cert"
$resourceGroup = $deploymentName + "group"
$fileShareStorageName = $deploymentName + "fileshare"
$scriptStorageName = $deploymentName + "script"
$keyVaultName = $deploymentName + "keyvault"
$serviceFabricClusterName = $deploymentName + "servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"

## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\..\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $machineAdminPass
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Create storage account
$containerName = "extensionscripts"
$fileShareName = "sfdatapath"
$extensionMountScriptFileName = "Mount-FileShare.ps1"
$extensionMountScriptFilePath = ".\Mount-FileShare.ps1"
$extensionImpersonateScriptFileName = "Impersonate-Script.ps1"
$extensionImpersonateScriptFilePath = ".\Impersonate-Script.ps1"
$scriptStorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $scriptStorageName -Location $azureRegion -SkuName Standard_LRS -Kind StorageV2
$scriptStorageAccountContext = $scriptStorageAccount.Context
New-AzStorageContainer -Name $containerName -Context $scriptStorageAccountContext -Permission blob
$uploadedBlobContent1 = Set-AzStorageBlobContent -File $extensionMountScriptFileName -Container $containerName -Blob $extensionMountScriptFilePath -Context $scriptStorageAccountContext 
$uploadedBlobContent2 = Set-AzStorageBlobContent -File $extensionImpersonateScriptFilePath -Container $containerName -Blob $extensionImpersonateScriptFileName -Context $scriptStorageAccountContext 

$fileShareStorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $fileShareStorageName -Location $azureRegion -SkuName Premium_LRS -Kind FileStorage
$fileShareStorageAccountContext = $fileShareStorageAccount.Context
New-AzRmStorageShare -ResourceGroupName $resourceGroup -StorageAccountName $fileShareStorageName -Name $shareName -QuotaGiB 1024
$fileShare = Get-AzStorageShare -Context $fileShareStorageAccountContext | Where-Object { $_.Name -eq $shareName -and $_.IsSnapshot -eq $false }

$extensionMountScriptFileUri = $uploadedBlobContent1.ICloudBlob.uri.AbsoluteUri
$extensionImpersonateScriptFileUri =  $uploadedBlobContent2.ICloudBlob.uri.AbsoluteUri
$fileShareStorageAccountName = $fileShareStorageName
$fileShareStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $fileShareStorageName)[0].Value
$fileShareEndpoint = $fileShare.StorageUri.PrimaryUri.Host

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $machineAdminPass)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
$armParameter.Add("extensionImpersonateScriptFileUri", $extensionImpersonateScriptFileUri)
$armParameter.Add("extensionMountScriptFileUri", $extensionMountScriptFileUri)
$armParameter.Add("fileShareStorageAccountName", $fileShareStorageAccountName)
$armParameter.Add("fileShareStorageAccountKey", $fileShareStorageAccountKey)
$armParameter.Add("fileShareEndpoint", $fileShareEndpoint)
$armParameter.Add("fileShareName", $fileShareName)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Incremental

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $machineAdminPass -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"

