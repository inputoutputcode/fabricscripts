
$clusterUrl = ""
$serverThumbprint = ""
$nodeName = "_backend_9"
$nodeState = ""

Connect-ServiceFabricCluster -ConnectionEndpoint $clusterUrl -ServerCertThumbprint $serverThumbprint -AzureActiveDirectory

Disable-ServiceFabricNode -NodeName $nodeName -Intent RemoveNode

while ($nodeState -notcontains "Disabled")
{
    $nodeState = Get-ServiceFabricNode -NodeName $nodeName -StatusFilter Removed -TimeoutSec 10
    $nodeState
    Start-Sleep -Seconds 10
}


