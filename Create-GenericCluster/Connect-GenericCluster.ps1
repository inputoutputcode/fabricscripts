
$ConnectArgs = @{  
        ConnectionEndpoint = 'chrpap020419-servicefabric.centralus.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "chrpap020419-servicefabric.centralus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "FC65B977AF93294E2CFFA800FAADDE73D92BEB7F"   
    }
Connect-ServiceFabricCluster @ConnectArgs

