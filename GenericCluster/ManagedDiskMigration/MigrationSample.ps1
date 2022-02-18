$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$password = "Password#1234" | ConvertTo-SecureString -AsPlainText -Force
$resourceGroupName = "quickstart-sf-group"
$keyVaultResourceGroupName = " quickstart-kv-group"
$keyVaultName = "quickstart-kv"
$azureRegion = "southcentralus"
$clusterDnsName = "{0}.{1}.cloudapp.azure.com" -F $resourceGroupName, $azureRegion
$localCertificateFolder = "D:\Certificates"

$templateFileStepOne = "1NodeType-UnmanagedDisks-Tweak.json"
$templateFileParameterStepOne = "1NodeType-UnmanagedDisks.parameters.json"
$templateFileStepTwo = "1NodeType-2ScaleSets-Tweak.json"
$templateFileParameterStepTwo = "1NodeType-UnmanagedDisks.parameters.json"

$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Create-GenericCluster\ManagedDiskMigration"
cd $currentExecutionPath

Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

New-AzServiceFabricCluster -ResourceGroupName $resourceGroupName -TemplateFile $templateFileStepOne -ParameterFile $templateFileParameterStepOne -CertificateOutputFolder $localCertificateFolder -CertificatePassword $password -KeyVaultResourceGroupName $keyVaultResourceGroupName  -KeyVaultName $keyVaultName -CertificateSubjectName $clusterDnsName


   # Connect to the cluster and check the cluster health.
Connect-ServiceFabricCluster -ConnectionEndpoint $serviceFabricClusterDns -KeepAliveIntervalInSec 10 `
    -X509Credential `
    -ServerCertThumbprint $clusterCertificate.CertificateThumbprint  `
    -FindType FindByThumbprint `
    -FindValue $clusterCertificate.CertificateThumbprint `
    -StoreLocation CurrentUser `
    -StoreName My 
    
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
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateParameterFile $templateFileParameterStepTwo -TemplateFile $templateFileStepTwo -Verbose 

# Check the cluster health again. All 15 nodes should be healthy.
Get-ServiceFabricClusterHealth

# Disable the nodes in the original scale set.
$nodeNames = @("_NTvm1_0","_NTvm1_1","_NTvm1_2","_NTvm1_3","_NTvm1_4")

Write-Host "Disabling nodes..."
ForEach($name in $nodeNames){
    Disable-ServiceFabricNode -NodeName $name -Intent RemoveNode -Force
} 

# Remove the scale set
$scaleSetName="NTvm1"
Remove-AzVmss -ResourceGroupName $groupname -VMScaleSetName $scaleSetName -Force
Write-Host "Removed scale set $scaleSetName" 

ForEach($name in $nodeNames){
    # Remove the node from the cluster
    Remove-ServiceFabricNodeState -NodeName $name -TimeoutSec 300 -Force
    Write-Host "Removed node state for node $name"
} 