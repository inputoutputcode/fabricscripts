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
