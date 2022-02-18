Connect-ServiceFabricCluster

Get-ServiceFabricApplication -ApplicationName "fabric:/WordCount"

Get-ServiceFabricService -ApplicationName "fabric:/WordCount" -ServiceName "fabric:/WordCount/WordCountService"

Update-ServiceFabricService -Stateful "fabric:/WordCount/WordCountService" -TargetReplicaSetSize 3 -MinReplicaSetSize 2 -Force

Get-ServiceFabricReplica -PartitionId 7e2211fe-4970-43eb-8e62-9e1ba6cf0871


Update-ServiceFabricService -Stateless "fabric:/XRayApp/Web" -InstanceCount -1