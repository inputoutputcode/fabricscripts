
Login-AzAccount

Get-AzSubscription

$subscriptionId = ""
Set-AzContext -SubscriptionId $subscriptionId

$envName = "chrpapdev"
$saName = "blobbackup$($envName)"
$apimName="chrpapapigateway$($envName)"
$automationResourceGroupName = "spp-automation-$($envName)"
		
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $automationResourceGroupName -StorageAccountName $saName)[0].Value
$storageContext = New-AzStorageContext -StorageAccountName $saName -StorageAccountKey $storageKey

$container = Get-AzStorageContainer -Context $storageContext
$targetContainerName = "apimbackup"

@(Get-AzStorageBlob -Context $storageContext -Container $targetContainerName | ?{$_.LastModified.DateTime -lt [System.DateTime]::UtcNow.AddDays(-30)})


$dataBricksSystemGroup = "spp-databricks-res-$($envName)"
$resourceGroupNames = Get-AzResourceGroup | where { $_.ResourceGroupName -ne $dataBricksSystemGroup }

foreach($resourceGroupName in $resourceGroupNames)
{
$resourceGroupName.ResourceGroupName
    $deployments = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName.ResourceGroupName
    $deploymentsToDelete = $deployments | where { $_.Timestamp -lt ((get-date).AddDays(-1*$HistoryDays)) }

    Write-Output $("Deployments to delete in $($ressourceGroupName.ResourceGroupName): $($deploymentsToDelete.count)")

    foreach ($deployment in $deploymentsToDelete) {	
            Write-Output  "Removing" $deployment.DeploymentName	
            #Remove-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName.ResourceGroupName -DeploymentName $deployment.DeploymentName
            $resourceGroupName.ResourceGroupName
            $deployment.DeploymentName
            Write-Output "Done removing" 

    }
}
