$resourceGroup = "chrpap012051-group"
$vmName = "mgmt_0"

Login-AzAccount

$subscriptionName = "Service Fabric Team - Temporary Testing"
$subscriptionId = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzSub
Get-AzVmssVm -ResourceGroupName $resourceGroup -Name $vmName




$vmss = New-AzureRmVmssConfig -Location $Loc -SkuCapacity 2 -SkuName "Standard_A0" -UpgradePolicyMode "Automatic"
$vmss = Add-AzureRmVmssDataDisk -VirtualMachineScaleSet $vmss -Name 'DataDisk1' -Lun 0 -Caching 'ReadOnly' -CreateOption Empty -DiskSizeGB 10 -StorageAccountType StandardLRS 

$vmss = Add-AzureRmVmssVMDataDisk -VirtualMachineScaleSetVM $vmss -Lun 0 -CreateOption Attach -ManagedDiskId  -Caching None


Enable-AzureRmAlias

$resourceGroup = "chrpap00-vmssgame"
$scaleSetName = "mgmt"
$location = "westus"
New-AzResourceGroup -Name $resourceGroup -Location $location

New-AzVmss `
  -ResourceGroupName "myResourceGroupScaleSet" `
  -Location "EastUS" `
  -VMScaleSetName "myScaleSet" `
  -VirtualNetworkName "myVnet" `
  -SubnetName "mySubnet" `
  -PublicIpAddressName "myPublicIPAddress" `
  -LoadBalancerName "myLoadBalancer" `
  -UpgradePolicyMode "Automatic"

$vmss = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_A0" -UpgradePolicyMode "Automatic"

$disk = Get-AzDisk -ResourceGroupName $rgname -DiskName $diskname0
$VmssVM = Get-AzVmssVM -ResourceGroupName "myrg" -VMScaleSetName "myvmss" -InstanceId 0
$VmssVM = Add-AzVmssVMDataDisk -VirtualMachineScaleSetVM $VmssVM -Lun 0 -DiskSizeInGB 10 -CreateOption Attach -StorageAccountType Standard_LRS -ManagedDiskId $disk.Id
Update-AzVmssVM -VirtualMachineScaleSetVM $VmssVM

