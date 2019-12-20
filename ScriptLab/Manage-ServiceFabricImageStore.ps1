

Connect-ServiceFabricCluster



(Get-ImageStoreConnectionStringFromClusterManifest(Get-ServiceFabricClusterManifest))

Get-ServiceFabricImageStoreContent

Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store\TestImageStoreAppType"

Remove-ServiceFabricApplicationPackage - -ApplicationPackagePathInImageStore "TestImageStoreAppType@4.0.1" 

Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore "TestImageStoreAppType"


# OLD

Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store"


Get-ServiceFabricImageStoreContent -RemoteRelativePath "TestImageStoreAppType"

Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store\TestImageStoreAppType"

Get-ServiceFabricImageStoreContent -ApplicationTypeName "TestImageStoreAppType" -ApplicationTypeVersion "1.0.2" -ImageStoreConnectionString "fabric:ImageStore"


Get-ServiceFabricRepairTask

$packagePath = "C:\Code\TestImageStoreApp\TestImageStoreApp\pkg\debug"
$appName = "TestImageStoreApp"
$appTypeName = $appName + "Type"
$appVersion = "4.0.1"
Copy-ServiceFabricApplicationPackage $packagePath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $appTypeName -CompressPackage:$True -ShowProgress
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $appName

New-ServiceFabricApplication -ApplicationName $appName -ApplicationTypeName appName -ApplicationTypeVersion $appVersion 
Start-ServiceFabricApplicationUpgrade -ApplicationName "fabric:/TestImageStoreApp" -ApplicationTypeVersion $appVersion -UnMonitoredManual

Unregister-ServiceFabricApplicationType -ApplicationTypeName $appName -ApplicationTypeVersion "1.0.2" -Force -Async 