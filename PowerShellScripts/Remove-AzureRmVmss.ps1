$subscriptionId = ""
$tenantId = ""

Connect-AzureRmAccount -SubscriptionId $subscriptionId -TenantId $tenantId

$resourceGroup = "chrpapdev"
$scaleSetName = "backend"
$instanceId = "9"

Remove-AzureRmVmss -ResourceGroupName $resourceGroup -VMScaleSetName $scaleSetName -InstanceId $instanceId
