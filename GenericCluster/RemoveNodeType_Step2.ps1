$groupname = "chrpap260146-group"
$nodetype = "scaletmp"
$clustername = "chrpap260146-servicefabric"

Connect-ServiceFabricCluster -ConnectionEndpoint chrpap260146-servicefabric.centralus.cloudapp.azure.com:19000 `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint D1FE6AE404699A3DAA0C747D21D943B4810576B8 `
          -FindType FindByThumbprint -FindValue D1FE6AE404699A3DAA0C747D21D943B4810576B8 `
          -StoreLocation CurrentUser -StoreName My

$nodes = Get-ServiceFabricNode | Where-Object {$_.NodeType -eq $nodetype} | Sort-Object { $_.NodeName.Substring($_.NodeName.LastIndexOf('_') + 1) } -Descending

Foreach($node in $nodes)
{
    Remove-ServiceFabricNodeState -NodeName $node.NodeName -TimeoutSec 300 -Force 
}