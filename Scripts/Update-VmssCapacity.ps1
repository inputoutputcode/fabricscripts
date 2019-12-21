# Ref: https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-manage-powershell#change-the-capacity-of-a-scale-set

$subscriptionId = "" 
$tenantId = ""

Connect-AzureRmAccount -SubscriptionId $subscriptionId -TenantId $tenantId

$resourceGroup = "chrpapdev"
$scaleSetName = "backend"
$targetCapacity = 10

# Get current scale set
$vmss = Get-AzureRmVmss -ResourceGroupName $resourceGroup -VMScaleSetName $scaleSetName

# Set and update the capacity of your scale set
if ($vmss.sku.capacity -lt $targetCapacity)
{
    $vmss.sku.capacity = $targetCapacity
    Update-AzureRmVmss -ResourceGroupName resourceGroup -Name $scaleSetName -VirtualMachineScaleSet $vmss -Verbose
}