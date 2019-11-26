$groupname = "chrpap260146-group"
$nodetype = "scaletmp"
$clustername = "chrpap260146-servicefabric"

Remove-AzServiceFabricNodeType -Name $clustername  -NodeType $nodetype -ResourceGroupName $groupname

