# Parameters
$subscriptionName = ""
$resourceGroupName = ""
$clusterName = ""

# Check AZ module version
Get-InstalledModule -Name "Az" -MinimumVersion 1.1.0 
Get-InstalledModule -Name "Az.Compute" -MinimumVersion 2.2.0 
Get-InstalledModule -Name "Az.ServiceFabric" -MinimumVersion 1.1.0


# Get the patching history
Login-AzAccount

Get-AzSubscription 

Select-AzSubscription $subscriptionName

Get-AzServiceFabricCluster | Select Name

Get-AzServiceFabricCluster | Select NodeTypes

Get-AzServiceFabricCluster -ResourceGroupName $resourceGroupName -ClusterName $clusterName

Get-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName "backend" -OSUpgradeHistory 
# 2016.127.20190603

# Get list of os images
Get-AzVmImage -Location "westeurope" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter-with-Containers"

# Current version
Get-AzVmssVM -ResourceGroupName spp-servicefabric-dev01 -VMScaleSetName backend -InstanceId 0  | Select Version
# Result: 2016.127.20190603


$url = "https://management.azure.com/subscriptions/spp-servicefabric-dev01/resourceGroups/spp-servicefabric-dev01/providers/Microsoft.Compute/virtualMachineScaleSets/backend/osUpgradeHistory?api-version=2018-06-01"


# Parameters
$subscriptionName = "Van_SPP_Dev01"
$resourceGroupName = "spp-servicefabric-dev01"
$clusterName = "spp-cluster-dev01"

$envName = "dev01"
$fabricResourceGroupName = "spp-servicefabric-$($envName)"

Login-AzAccount

Select-AzSubscription $subscriptionName

$vmss = Get-AzVmss -ResourceGroupName $fabricResourceGroupName | Select Name
ForEach ($scaleSetName in $vmss) {
	Write-Output "-- VMSS: $($scaleSetName.Name)"
	$results = Get-AzVmss -ResourceGroupName $fabricResourceGroupName -VMScaleSetName $scaleSetName.Name -OSUpgradeHistory
    $entryCount = 0

    ForEach ($result in $results) {
        Write-Output "-- Entry #$($entryCount)"
        $entryCount++
        Write-Output "TargetVersion: $($result.Properties.TargetImageReference.Version)"
        Write-Output "StartTime $($result.Properties.RunningStatus.StartTime)"
        Write-Output "Status: $($result.Properties.RunningStatus.Code)"
        Write-Output "$($result.Properties.Progress.SuccessfulInstanceCount) = SuccessfulInstanceCount"
        Write-Output "$($result.Properties.Progress.FailedInstanceCount) = FailedInstanceCount"
        Write-Output "$($result.Properties.Progress.InProgressInstanceCount) = InProgressInstanceCount"
        Write-Output "$($result.Properties.Progress.PendingInstanceCount) = PendingInstanceCount"
        write-Output " "
        If ($result.Properties.Error.Details.Count -gt 0) {
            $errorCount = 0
            ForEach ($errorData in $result.Properties.Error.Details) {
                Write-Output "-- Error #$($errorCount)"
                $errorCount++
                Write-Output "Code: $($errorData.Code)"
                Write-Output "Target: $($errorData.Target)"
                Write-Output "Message: $($errorData.Message)"
                write-Output " "
            }
        } 
    }
}