Connect-ServiceFabricCluster


$replicas = Get-ServiceFabricPartition -ServiceName fabric:/System/DnsService | Get-ServiceFabricReplica
ForEach ($replica in $replicas)
{
    $oldReplicaId = $replica.InstanceId
    $newReplicaId = $replica.InstanceId

    $replica | Remove-ServiceFabricReplica 

    Do
    {
        Start-Sleep -Seconds 5
        $newReplica = Get-ServiceFabricReplica -PartitionId 19754967-543a-4e29-a060-8867cf0b4561 -NodeName $replica.NodeName
        
        $newReplicaId = $newReplica.InstanceId
    }
    While ($newReplicaId -ne $oldReplicaId)
    Start-Sleep -Seconds 5
}

