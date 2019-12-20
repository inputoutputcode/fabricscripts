# Addon for logging
filter timestamp {"$(Get-Date -Format G): $_"}

# Connect to the cluster
$clusterUrl = ""
$serverThumbprint = 
Connect-ServiceFabricCluster -ConnectionEndpoint $clusterUrl -ServerCertThumbprint $serverThumbprint -AzureActiveDirectory

# 1 13/02/2019@3:03pm
$serviceName = "fabric:/chrpapdev"
$partitionId = ""
$nodeName = "_backend_4"
Move-ServiceFabricPrimaryReplica -PartitionId $partitionId -NodeName $nodeName -ServiceName $serviceName
