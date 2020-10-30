$resourceGroup = "chrpap241125group"
$serviceFabricClusterName = "chrpap241125servicefabric"
$certificateThumbprint = "CD290B3CE77A0905A8FD5F86FB388390C6670787"
$serviceFabricClusterDns = "chrpap241125servicefabric.westus.cloudapp.azure.com"

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

$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}
Enable-AzureRmAlias
Set-ServiceFabricClusterUpgrade -MaxPercentUnhealthyApplications 50 -HealthCheckRetryTimeoutSec 300 -HealthCheckWaitDurationSec 60 -HealthCheckStableDurationSec 60 -UpgradeDomainTimeoutSec 180 -UpgradeTimeoutSec 660 -MaxPercentUnhealthyNodes 20 -InstanceCloseDelayDurationSec 60  -Force 

#Get-ServiceFabricRuntimeUpgradeVersion -BaseVersion "7.0.457.9590"
#Set-AzServiceFabricUpgradeType -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName -UpgradeMode Manual -Version "7.0.466.9590"
#Set-AzServiceFabricUpgradeType -ResourceGroupName $resourceGroup -Name $serviceFabricClusterName -UpgradeMode Manual -Version "7.1.417.9590"