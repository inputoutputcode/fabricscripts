$deploymentName = "chrpap090234"
$ConnectArgs = @{  
        ConnectionEndpoint = $deploymentName + "-servicefabric.centralus.cloudapp.azure.com:19000";  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = $deploymentName + "-servicefabric.centralus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "2F916B3A443F55062794EDA7F82B55301FF9D073"   
    }
Connect-ServiceFabricCluster @ConnectArgs


$nodetype="backend" # specify the name of node type
$nodes=Get-ServiceFabricNode
foreach($node in $nodes)
{
  if ($node.NodeType -eq $nodetype)
  {
    $node.NodeName
    $nodename = $node.NodeName
 
    Disable-ServiceFabricNode -Intent RemoveNode -NodeName $nodename -Force
  }
}

foreach($node in $nodes)
{
  if ($node.NodeType -eq $nodetype)
  {
    $node.NodeName
    $nodename = $node.NodeName
 
    Start-ServiceFabricNodeTransition -Stop -OperationId (New-Guid) -NodeInstanceId $node.NodeInstanceId -NodeName $node.NodeName -StopDurationInSeconds 10000
  }
}

foreach($node in $nodes)
{
  if ($node.NodeType -eq $nodetype)
  {
$node.NodeName
    $nodename = $node.NodeName
 
    Remove-ServiceFabricNodeState -NodeName $nodename -Force
  }
}

## get the current manifest
$timeStampString = (Get-Date).ToString("ddhhmmss")
$currentManifest = Get-ServiceFabricClusterManifest -ClusterManifestVersion "1"
$filePath = "C:\Scripts\" + $deploymentName + "_ClusterManifest_1.xml"
$currentManifest | Out-File -FilePath $filePath -Force

## edit the new cluster manifest manually
$filePathNew = "C:\Scripts\" + $deploymentName + "_ClusterManifest_2.xml"
Copy-ServiceFabricClusterPackage  -Config -ClusterManifestPath $filePathNew -ClusterManifestPathInImageStore "v2" 
Register-ServiceFabricClusterPackage -Config -ClusterManifestPath "v2"
Start-ServiceFabricClusterUpgrade -Config -ClusterManifestVersion "2" -Monitored  -FailureAction Rollback

## Get uptime for the node to detect restarts
$nodes = Get-ServiceFabricNode | Sort-Object -Property NodeName
ForEach($node in $nodes)
{
    Write-Host $node.NodeUpTime "|" $node.NodeUpAt "|" $node.NodeName
}

Get-ServiceFabricClusterUpgrade