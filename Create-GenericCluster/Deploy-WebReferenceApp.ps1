

$path = "D:\Code\service-fabric-dotnet-web-reference-app\ReferenceApp\WebReferenceApplication\pkg\Debug"

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

Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $path -CompressPackage -ApplicationPackagePathInImageStore WRA1 -TimeoutSec 1800

#Register FO ApplicationType:

Register-ServiceFabricApplicationType -ApplicationPathInImageStore WRA1 

#Create FO application (if not already deployed at lesser version):

New-ServiceFabricApplication -ApplicationName fabric:/WebReferenceApp -ApplicationTypeName WebReferenceAppType -ApplicationTypeVersion 3.1.11  

#OR if updating existing version:  

Start-ServiceFabricApplicationUpgrade -ApplicationName fabric:/WebReferenceApp -ApplicationTypeVersion 1.0.0 -Monitored -FailureAction rollback