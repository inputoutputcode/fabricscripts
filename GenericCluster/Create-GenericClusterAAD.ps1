## Declare parameters
$armTemplate = ".\Templates\Vortex-LoadTest-Cluster.json" # 
$currentExecutionPath = "C:\Code\FabricScripts\GenericCluster"
$azureRegion = "eastus"
$localCertificatePath = "C:\Certificates\"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"


## Auth
<#
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId 
# Set environment 
Try {
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId 
}
#>
# MSDN 
$tenantId = '7459bed2-8ead-4b9b-84ff-38402c19a97d' #'f1c9b125-e2bf-48c0-b025-23e47c410293'
$subscriptionId = "d715466f-2653-406f-be2f-495f7fd4e1b7"
Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId 

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
$webapplicationReplyUrl = "https://" + $serviceFabricClusterDns + ":19080/Explorer/index.html"
$omsName = $deploymentName + "-oms"



## Deploy Azure Key Vault
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment -EnabledForTemplateDeployment
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
#Start-Sleep -Seconds 120
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

# AAD setup
cd "$currentExecutionPath\MicrosoftAzureServiceFabric-AADHelpers"
$Configobj = .\SetupApplications.ps1 -TenantId $tenantId -ClusterName $serviceFabricClusterDns -WebApplicationReplyUrl $webapplicationReplyUrl
.\SetupUser.ps1 -ConfigObj $Configobj -UserName 'DemoLocalUser' -Password $generalPassword
.\SetupUser.ps1 -ConfigObj $Configobj -UserName 'DemoLocalAdmin' -Password $generalPassword -IsAdmin

<#
TenantId                       f1c9b125-e2bf-48c0-b025-23e47c410293   /7459bed2-8ead-4b9b-84ff-38402c19a97d                                                                                                                                                                                           
WebAppId                       9e776163-2766-4ea7-ae77-c74653b5e9b5                                                                                                                                                                                              
NativeClientAppId              248ccd52-abb1-403e-a53a-86711e151f31                                                                                                                                                                                              
ServicePrincipalId             2b84b565-f530-4143-a075-c2dbb291cfc2                                                                                                                                                                                              

-----ARM template-----
"azureActiveDirectory": {
  "tenantId":"f1c9b125-e2bf-48c0-b025-23e47c410293",
  "clusterApplication":"9e776163-2766-4ea7-ae77-c74653b5e9b5",
  "clientApplication":"248ccd52-abb1-403e-a53a-86711e151f31"
},
#>

cd $currentExecutionPath

## Deploy Azure Service Fabric Cluster
$armParameter = @{}
$armParameter.Add("deploymentId", $deploymentName)
#$armParameter.Add("clusterVersion", $clusterVersion)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)
##$armParameter.Add("omsWorkspaceName", $omsName)
##$armParameter.Add("clusterLocation", $azureRegion)
##$armParameter.Add("dnsName", $serviceFabricClusterName)


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



#Update-AzServiceFabricDurability -ResourceGroupName chrpap241050-group -Name chrpap241050-servicefabric -DurabilityLevel Silver -NodeType mngmt

# Start-AzVmssRollingOSUpgrade -ResourceGroupName "chrpap111911-group" -VMScaleSetName "mngmt"


