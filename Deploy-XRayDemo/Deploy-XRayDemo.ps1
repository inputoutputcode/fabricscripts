$packagepath = "C:\Repos\Scripts\Deploy-XRayDemo\XRayPackageSF5.6.220"
$applicationName = 'XRayApp'
$applicationTypeName = 'xrayType'
$version = '1.0.0'

$clusterEndpoint = "idctoyl4xb7x6-servicefabric.westeurope.cloudapp.azure.com:19000"
$clusterCertificateThumbprint = "7E841211FCFEC49DF64B3C77B9DEF6876CF583A8"

Connect-ServiceFabricCluster -ConnectionEndpoint $clusterEndpoint `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint $clusterCertificateThumbprint `
          -FindType FindByThumbprint -FindValue $clusterCertificateThumbprint `
          -StoreLocation CurrentUser -StoreName My

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $applicationName

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $applicationName

# Create the application instance.
$applicationPath = 'fabric:/' +  $applicationName
New-ServiceFabricApplication -ApplicationName $applicationPath -ApplicationTypeName $applicationTypeName -ApplicationTypeVersion $version
