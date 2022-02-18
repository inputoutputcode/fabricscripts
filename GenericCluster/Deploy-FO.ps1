$packagePath = "D:\Code\fo-binaries\"

$file1 = "Microsoft.ServiceFabricApps.FabricObserver.Windows.SelfContained.3.1.12.sfpkg"
$file2 = "Microsoft.ServiceFabricApps.FabricObserver.Windows.FrameworkDependent.3.1.12.sfpkg"
$file3 = "D:\Code\fo-binaries\Microsoft.ServiceFabricApps.FabricObserver.Windows.FrameworkDependent.3.1.12"


cd $packagePath

$package = $packagePath + $file2

Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $file3 -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore FabricObserver  -ShowProgress -ShowProgressIntervalMilliseconds 1 -TimeoutSec 60

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore FabricObserver

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore FabricObserver

# Create the application instance.
New-ServiceFabricApplication -ApplicationName fabric:/FabricObserver -ApplicationTypeName FabricObserverType -ApplicationTypeVersion 3.1.12