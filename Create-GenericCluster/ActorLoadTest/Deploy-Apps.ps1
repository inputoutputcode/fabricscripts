$ConnectArgs = @{  
ConnectionEndpoint = 'chrpap241338servicefabric.eastus.cloudapp.azure.com:19000';  
X509Credential = $True;  StoreLocation = 'CurrentUser';  
StoreName = "MY";  
ServerCommonName = "chrpap241338servicefabric.eastus.cloudapp.azure.com";  
FindType = 'FindByThumbprint';  
FindValue = "A6BF73E820B32198BF5A7EE0112EEDE629A566ED"   
}
Connect-ServiceFabricCluster @ConnectArgs

$packagepath = "D:\Code\service-fabric-dotnet-performance\ServiceLoadTest\ServiceFabric\Dictionary\SFDictionaryApplication\pkg\Release"
$applicationName = 'DictionaryApplication'
$applicationTypeName = 'DictionaryApplicationType'
$version = '1.0.0'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName -ShowProgress -ShowProgressIntervalMilliseconds 1 -TimeoutSec 60

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version


$packagepath = "D:\Code\service-fabric-dotnet-performance\ServiceLoadTest\ServiceFabric\Actor\SFActorApplication\pkg\Release"
$applicationName = 'ActorApplication'
$applicationTypeName = 'ActorApplicationType'
$version = '1.0.0'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName -ShowProgress -ShowProgressIntervalMilliseconds 1 -TimeoutSec 60

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName


$packagepath = "D:\Code\service-fabric-dotnet-performance\ServiceLoadTest\Framework\LoadDriverApplication\pkg\Release"
$applicationName = 'LoadDriverApplication'
$applicationTypeName = 'LoadDriverApplicationType'
$version = '1.0.0'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName -ShowProgress -ShowProgressIntervalMilliseconds 1 -TimeoutSec 60

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName



