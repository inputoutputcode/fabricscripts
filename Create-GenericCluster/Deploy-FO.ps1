$packagePath = "D:\Code\fo-binaries"

$file1 = "Microsoft.ServiceFabricApps.FabricObserver.Windows.SelfContained.3.1.12.sfpkg"
$file2 = "Microsoft.ServiceFabricApps.FabricObserver.Windows.FrameworkDependent.3.1.12.sfpkg"

cd $packagePath

Copy-ServiceFabricApplicationPackage - $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore FO

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore FO

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore FO

# Create the application instance.
New-ServiceFabricApplication -ApplicationName fabric:/MyApplication -ApplicationTypeName MyApplicationType -ApplicationTypeVersion 1.0.0