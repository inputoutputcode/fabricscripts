## Declare parameters
$armTemplate = ".\Templates\5-VM-Ubuntu-1-NodeTypes-Secure.json"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\GenericCluster"

## https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
##ssh-keygen -t ed25519 
##C:\Users\chrpap\.ssh\id_rsa
$sshPubKey = "ssh-rsa XXX"
## https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop

## Fixed parameters
$azureRegion = "centralus"
$localCertificatePath = "D:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"

## COPR subscription
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
# Set environment 
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
$tag = New-AzTag -Name "alias"
$group = New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Tag @{"alias"="chrpap"}
Write-Host "Created the resource group" $group.ResourceGroupName
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true" 
$keyVault = New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Write-Host "Created the resource group" $keyVault.VaultName
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("adminPublicKey", $sshPubKey)
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

## Create pem file
$certStorePath = "Cert:\CurrentUser\My\" + $clusterCertificate.CertificateThumbprint
$derCertFilePath = $localCertificatePath + $certificateName + ".der"
Export-Certificate -Cert $certStorePath -FilePath $derCertFilePath -type CERT –noclobber | Out-Null
$pemCertFilePath = $localCertificatePath + $certificateName + ".pem"
certutil -encode $derCertFilePath $pemCertFilePath | Out-Null



## Output
$output = "Deployment Name: $deploymentName; Thumbprint: " + $clusterCertificate.CertificateThumbprint
Write-Host $output
$output | Out-File -FilePath "C:\Temp\$deploymentName.txt"