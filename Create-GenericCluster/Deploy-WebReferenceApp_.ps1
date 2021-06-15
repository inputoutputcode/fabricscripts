$path = "D:\Code\service-fabric-dotnet-web-reference-app\ReferenceApp\WebReferenceApplication\pkg\Debug"
cd $path

$ConnectArgs = @{  
        ConnectionEndpoint = 'chrpap111911-servicefabric.eastus.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "chrpap111911-servicefabric.eastus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "D9B0B2356F55E3E3A41236061539771F31FFB0E5"   
    }
Connect-ServiceFabricCluster @ConnectArgs


#Copy $path contents (FO app package) to server:

Copy-ServiceFabricApplicationPackage $path -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore WRA1 -Verbose

#Register FO ApplicationType:

Register-ServiceFabricApplicationType -ApplicationPathInImageStore WRA1 

Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore WRA1

#Create FO application (if not already deployed at lesser version):

New-ServiceFabricApplication -ApplicationName fabric:/WebReferenceApplication -ApplicationTypeName WebReferenceApplicationType -ApplicationTypeVersion 1.0.0 

#OR if updating existing version:  

Start-ServiceFabricApplicationUpgrade -ApplicationName fabric:/WebReferenceApp -ApplicationTypeVersion 1.0.0 -Monitored -FailureAction rollback



# Variables
$endpoint = 'mysftestcluster.southcentralus.cloudapp.azure.com:19000'
$thumbprint = '2779F0BB9A969FB88E04915FFE7955D0389DA7AF'
$packagepath="C:\Users\sfuser\Documents\Visual Studio 2017\Projects\MyApplication\MyApplication\pkg\Release"

# Connect to the cluster using a client certificate.
Connect-ServiceFabricCluster -ConnectionEndpoint $endpoint `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint $thumbprint `
          -FindType FindByThumbprint -FindValue $thumbprint `
          -StoreLocation CurrentUser -StoreName My

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore MyApplication

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore MyApplication

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore MyApplication

# Create the application instance.
New-ServiceFabricApplication -ApplicationName fabric:/MyApplication -ApplicationTypeName MyApplicationType -ApplicationTypeVersion 1.0.0