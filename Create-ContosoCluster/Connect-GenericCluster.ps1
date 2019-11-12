$ConnectArgs = @{  
        ConnectionEndpoint = 'xffkewcpyja4-servicefabric.westeurope.cloudapp.azure.com:19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = "xffkewcpyja4-servicefabric.westeurope.cloudapp.azure.com";  
        FindType = 'FindByThumbprint';  
        FindValue = "EAC711D4DC26382A9BD02FFC0FC0153C04FAA090"   
    }
Connect-ServiceFabricCluster @ConnectArgs