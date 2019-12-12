Connect-ServiceFabricCluster -ConnectionEndpoint chrpap041232-servicefabric.centralus.cloudapp.azure.com:19000 `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint 60F3E3DB09EDCE2F49BB6CBC1307C8A398E74177 `
          -FindType FindByThumbprint -FindValue 60F3E3DB09EDCE2F49BB6CBC1307C8A398E74177 `
          -StoreLocation CurrentUser -StoreName My

$nodes = Get-ServiceFabricNode | Where-Object {$_.NodeType -eq $nodetype} | Sort-Object { $_.NodeName.Substring($_.NodeName.LastIndexOf('_') + 1) } -Descending

Foreach($node in $nodes)
{
    Remove-ServiceFabricNodeState -NodeName $node.NodeName -TimeoutSec 300 -Force 
}