
$ConnectArgs = @{  
        ConnectionEndpoint = 'chrpap090258-servicefabric.centralus.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "chrpap090258-servicefabric.centralus.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "10E451B0E686C9A48B81D5BF62FE90A7D414548B"   
    }
Connect-ServiceFabricCluster @ConnectArgs

