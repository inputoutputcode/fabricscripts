
## Set parameters
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$localCertificatePath = "D:\Certificates\"
$azureRegion = "centralus"
$generalPassword = "nZ549Ux2MnW6srTvOZsq"
$adminUserName = "Christian"
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
$certificateName = $deploymentName + "-cert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\ManagedDiskMigration"
cd $currentExecutionPath

## Login into Azure
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
    
## Generate the certificate
New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force 
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment
Import-Module ".\..\CertificateHelpers\CertificateHelpers.psm1" 
Enable-AzureRmAlias ## Still needed for Service Fabric RP Helpers
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword

## Import certificate in local store
$certificateFile = $localCertificatePath + $certificateName + ".pfx"
$certificatePassword = ConvertTo-SecureString $generalPassword -AsPlainText -Force
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath $certificateFile -Password $certificatePassword
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\TrustedPeople -FilePath $certificateFile -Password $certificatePassword

## Set dynamic parameters
$armParameter = @{}
$armParameter.Add("clusterLocation", $azureRegion)
$armParameter.Add("clusterName", $serviceFabricClusterName)
$armParameter.Add("computeLocation", $azureRegion)
$armParameter.Add("adminUserName", $adminUserName)
$armParameter.Add("adminPassword", $generalPassword)
$armParameter.Add("dnsName", $serviceFabricClusterDns)
$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)

# Deploy the one node type cluster with unmanaged disks.
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateParameterObject $armParameter `
    -TemplateFile "1NodeType-UnmanagedDisks.json" -Verbose 

Import-Module Az.ServiceFabric
$clusterState = (Get-AzServiceFabricCluster -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName).ClusterState

if (!($clusterState -eq "Ready")) {   
    do {   
        Write-host "Waiting for cluster state ready"
        Start-Sleep -s 30    # Wait 5 seconds  
        $clusterState = (Get-AzServiceFabricCluster -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName).ClusterState 
    } until($clusterState -eq "Ready")   
}   
Write-host "Cluster state is ready" -ForegroundColor Green  

# Connect to the cluster and check the cluster health.
$connectArgs = @{  
        ConnectionEndpoint = $serviceFabricClusterDns + ':19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = $serviceFabricClusterDns;  
        FindType = 'FindByThumbprint';  
        FindValue = $clusterCertificate.CertificateThumbprint  
    }
Connect-ServiceFabricCluster @connectArgs

Get-ServiceFabricClusterHealth

# Deploy a new scale set into the primary node type.  
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateParameterObject $armParameter `
    -TemplateFile "2NodeType-2ScaleSets-1LBPIP.json" -Verbose 

# Check the cluster health again. All 15 nodes should be healthy.
Get-ServiceFabricClusterHealth

# Disable the nodes in the original scale set.
$nodeNames = @("_NTvm1_0","_NTvm1_1","_NTvm1_2","_NTvm1_3","_NTvm1_4")

Write-Host "Disabling nodes..."
foreach($name in $nodeNames){
    Disable-ServiceFabricNode -NodeName $name -Intent RemoveNode -Force
} 

# Remove the scale set
$scaleSetName="NTvm1"
Remove-AzVmss -ResourceGroupName $groupname -VMScaleSetName $scaleSetName -Force
Write-Host "Removed scale set $scaleSetName" 

foreach($name in $nodeNames){
    # Remove the node from the cluster
    Remove-ServiceFabricNodeState -NodeName $name -TimeoutSec 300 -Force
    Write-Host "Removed node state for node $name"
} 
