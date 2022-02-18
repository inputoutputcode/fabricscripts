

$scaleset = Get-AzVmss -ResourceGroupName chrpap180518-group -VMScaleSetName frontend
$scaleset.Sku.Capacity += 1

Update-AzVmss -ResourceGroupName $scaleset.ResourceGroupName -VMScaleSetName $scaleset.Name -VirtualMachineScaleSet $scaleset

