
$ConnectArgs = @{  
        ConnectionEndpoint = 'chrpap021121-servicefabric.centralus.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "chrpap021121-servicefabric.centralus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "BF71968B52098A7873B607C49354B3D4CB53C69A"   
    }
Connect-ServiceFabricCluster @ConnectArgs




