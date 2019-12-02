$nodetype="backend"
$nodes=Get-ServiceFabricNode
foreach($node in $nodes)
{
  if ($node.NodeType -eq $nodetype)
  {
    $node.NodeName
    $nodename = $node.NodeName
 
    Start-ServiceFabricNodeTransition -Stop -OperationId (New-Guid) -NodeInstanceId $node.NodeInstanceId -NodeName $node.NodeName -StopDurationInSeconds 10000
  }
}
