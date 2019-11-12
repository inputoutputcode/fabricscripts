# Variables
$endpoint = 'vortex-servicefabric.westeurope.cloudapp.azure.com:19000'
$thumbprint = 'D342B62751810619AB806DD4733D088EEE7E5CDF'
$version = '1.0.0'

# Connect to the cluster using a client certificate.
Connect-ServiceFabricCluster -ConnectionEndpoint $endpoint `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint $thumbprint `
          -FindType FindByThumbprint -FindValue $thumbprint `
          -StoreLocation CurrentUser -StoreName My

#Connect-ServiceFabricCluster "localhost:19000"

$releaseMode = "Release" #Debug
$pathId = "MKVIT171103"


$packagepath = "C:\Code\" + $pathId + "\Backend\FunctionalComponents\ClientOpenCloseFinalizeApp\pkg\" + $releaseMode
$applicationName = 'ClientOpenCloseFinalizeApp'
$applicationTypeName = 'ClientOpenCloseFinalizeAppType'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version




$packagepath = "C:\Code\" + $pathId + "\Backend\PdlModuleControl\PdlModuleControlApp\pkg\" + $releaseMode
$applicationName = 'PdlModuleControlApp'
$applicationTypeName = 'PdlModuleControlAppType'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version




$packagepath = "C:\Code\" + $pathId + "\Backend\SessionManagement\SessionManagementApp\pkg\" + $releaseMode
$applicationName = 'SessionManagementApp'
$applicationTypeName = 'SessionManagementAppType'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version





$packagepath = "C:\Code\" + $pathId + "\Backend\GeneralModuleControl\GeneralModuleControlApp\pkg\" + $releaseMode
$applicationName = 'GeneralModuleControlApp'
$applicationTypeName = 'GeneralModuleControlAppType'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version




$packagepath = "C:\Code\" + $pathId + "\Backend\FunctionalComponents\FunctionalComponentsApp\pkg\" + $releaseMode
$applicationName = 'SendungsausgabeApp'
$applicationTypeName = 'SendungsausgabeAppType'

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version

