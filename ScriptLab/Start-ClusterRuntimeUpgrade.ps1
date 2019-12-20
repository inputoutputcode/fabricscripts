

$subscriptionId = "" 
$tenantId = ""
$clusterurl = ""
$serverThumbprint = ""
$resourceGroupName = ""
$clusterName = "" 

Connect-AzureRmAccount -SubscriptionId $subscriptionId

Get-AzureRmServiceFabricCluster -ResourceGroupName $res_group_name | Select-Object Name, ClusterCodeVersion 

Get-ServiceFabricRuntimeUpgradeVersion -BaseVersion "6.2.301.9494" #$current_cluster_version

Set-AzureRmServiceFabricUpgradeType -ResourceGroupName $resourceGroupName -Name $clusterName -UpgradeMode Manual -Version "6.3.162.9494"

Connect-ServiceFabricCluster -ConnectionEndpoint $endpoint `
                             -KeepAliveIntervalInSec 10 `
                             -X509Credential -ServerCertThumbprint $thumbprint `
                             -FindType FindByThumbprint -FindValue $thumbprint `
                             -StoreLocation CurrentUser -StoreName My

Get-ServiceFabricClusterUpgrade