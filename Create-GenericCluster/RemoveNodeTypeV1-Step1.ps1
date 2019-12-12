$groupname = "chrpap041232-group"
$nodetype = "backend"
$clustername = "chrpap041232-servicefabric"

Remove-AzServiceFabricNodeType -Name $clustername  -NodeType $nodetype -ResourceGroupName $groupname

