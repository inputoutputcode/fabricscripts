$resourceGroup = "chrpap231539group"
$serviceFabricClusterName = "chrpap231539servicefabric"
$certificateThumbprint = "C044170914659228FA887808B08B468391A56DE2"
$serviceFabricClusterDns = "chrpap231539servicefabric.westus.cloudapp.azure.com"

$ConnectArgs = @{  
        ConnectionEndpoint = $serviceFabricClusterDns + ':19000';  
        X509Credential = $True;  
        StoreLocation = 'CurrentUser';  
        StoreName = "MY";  
        ServerCommonName = $serviceFabricClusterDns;  
        FindType = 'FindByThumbprint';  
        FindValue = $certificateThumbprint   
    }
Connect-ServiceFabricCluster @ConnectArgs

Set-ServiceFabricClusterUpgrade -MaxPercentUnhealthyApplications 50 -HealthCheckRetryTimeoutSec 300 -HealthCheckWaitDurationSec 60 -HealthCheckStableDurationSec 60 -UpgradeDomainTimeoutSec 180 -UpgradeTimeoutSec 660 -MaxPercentUnhealthyNodes 20 -InstanceCloseDelayDurationSec 60  -Force 


#Get-ServiceFabricRuntimeUpgradeVersion -BaseVersion "7.0.457.9590"
#Set-AzServiceFabricUpgradeType -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName -UpgradeMode Manual -Version "7.0.466.9590"
#Set-AzServiceFabricUpgradeType -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName -UpgradeMode Manual -Version "7.1.417.9590"