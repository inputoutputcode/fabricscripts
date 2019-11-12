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