

$resourceGroup
$scaleSetName
$vmInstanceId


Disable-ServiceFabricNode


# To Restart the service fabric node process, not the VM, can help to fix hanging process.
# But be aware that if the Fabric.exe process needs more time, this action is a kind of node failure, so this is not a graceful restart
# Restart-ServiceFabricNode


Restart-AzureRmVmss -ResourceGroupName $resourceGroup -VMScaleSetName $scaleSetName -InstanceId $vmInstanceId



Get-AzureRmVmss


Stop-ServiceFabricNode


Start-ServiceFabricNode


