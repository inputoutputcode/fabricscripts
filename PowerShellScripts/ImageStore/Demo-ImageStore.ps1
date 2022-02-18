$ConnectArgs = @{  
        ConnectionEndpoint = 'oojgkfvxdvnhe-servicefabric.westeurope.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "oojgkfvxdvnhe-servicefabric.westeurope.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "B534D033639F5069F8C8E556888A0297F5F5357F"   
    }
Connect-ServiceFabricCluster @ConnectArgs

# Base parameters
$packagePath = "C:\Customer\adVANce\PowerShell\Demo.ImageStore\"

$pathVersion1 = "DemoFrontendWeb@1.0.0"
$pathVersion2 = "DemoFrontendWeb@2.0.0"
$pathVersion3 = "DemoFrontendWeb@3.0.0"

$storeFolderName = "DemoFrontendWebPkg"
$appTypeName = "Demo.SfImageStoreType"
$appUrl = "fabric:/Demo.SfImageStoreType/DemoFrontendWeb"
$storeUrl = "fabric:ImageStore"


Get-ServiceFabricImageStoreContent 
Get-ServiceFabricImageStoreContent -RemoteRelativePath "DemoFrontendWebPkg"
Get-ServiceFabricImageStoreContent -RemoteRelativePath "DemoFrontendWebPkg\DemoFrontendWebPkg"
Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store"
Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store\Demo.SfImageStoreType"

# Version 1.0.0 parameters
$targetPkgPath = $packagePath + $pathVersion1
$appVersion = "1.0.0"
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $targetPkgPath -ImageStoreConnectionString $storeUrl -ApplicationPackagePathInImageStore $storeFolderName -CompressPackage:$True -ShowProgress
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $storeFolderName
New-ServiceFabricApplication -ApplicationName $appUrl -ApplicationTypeName $appTypeName -ApplicationTypeVersion $appVersion


# Version 2.0.0 parameters
$targetPkgPath = $packagePath + $pathVersion2
$appVersion = "2.0.0"
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $targetPkgPath -ImageStoreConnectionString $storeUrl -ApplicationPackagePathInImageStore $storeFolderName -CompressPackage:$True -ShowProgress
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $storeFolderName
Start-ServiceFabricApplicationUpgrade -ApplicationName $appUrl -ApplicationTypeVersion $appVersion -UnmonitoredAuto


# Version 3.0.0 parameters
$targetPkgPath = $packagePath + $pathVersion3
$appVersion = "3.0.0"
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $targetPkgPath -ImageStoreConnectionString $storeUrl -ApplicationPackagePathInImageStore $storeFolderName -CompressPackage:$True -ShowProgress
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $storeFolderName 
Start-ServiceFabricApplicationUpgrade -ApplicationName $appUrl -ApplicationTypeVersion $appVersion -UnmonitoredAuto # -HealthCheckRetryTimeoutSec 1 -HealthCheckStableDurationSec 1 -HealthCheckWaitDurationSec 1


Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore $storeFolderName
Get-ServiceFabricImageStoreContent

Unregister-ServiceFabricApplicationType -ApplicationTypeName $appTypeName -ApplicationTypeVersion "1.0.0" -Force -Async 
Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store\Demo.SfImageStoreType"

Unregister-ServiceFabricApplicationType -ApplicationTypeName $appTypeName -ApplicationTypeVersion "2.0.0" -Force -Async 
Get-ServiceFabricImageStoreContent -RemoteRelativePath "Store\Demo.SfImageStoreType"