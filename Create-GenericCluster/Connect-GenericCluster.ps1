
$ConnectArgs = @{  
        ConnectionEndpoint = 'chrpap260146-servicefabric.centralus.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "chrpap260146-servicefabric.centralus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "D1FE6AE404699A3DAA0C747D21D943B4810576B8"   
    }
Connect-ServiceFabricCluster @ConnectArgs




