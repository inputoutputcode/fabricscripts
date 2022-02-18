$nodetype="backend"
$nodes=Get-ServiceFabricNode
foreach($node in $nodes)
{
  if ($node.NodeType -eq $nodetype)
  {
$node.NodeName
    $nodename = $node.NodeName
 
    Remove-ServiceFabricNodeState -NodeName $nodename -Force
  }
}
