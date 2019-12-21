
$clusterUrl = ""
$serverThumbprint = ""
Connect-ServiceFabricCluster -ConnectionEndpoint $clusterUrl -ServerCertThumbprint $serverThumbprint -AzureActiveDirectory


Get-ServiceFabricApplication -ApplicationName $appName
$appName = "fabric:/Watchdog"
$appVersion = "2.1.0.20180711.1.Release-47.1"
$appType = "WatchdogType"
$ImageStoreConnectionString = "fabric:ImageStore"
Remove-ServiceFabricApplication -ApplicationName $appName -ForceRemove -Verbose
Get-ServiceFabricApplicationType -ApplicationTypeName $appType
Unregister-ServiceFabricApplicationType -ApplicationTypeName $appType -ApplicationTypeVersion $appVersion -Force
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore $appType -ImageStoreConnectionString $ImageStoreConnectionString

Get-ServiceFabricImageStoreContent













