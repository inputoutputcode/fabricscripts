$vmssName = "chrpap-vmss"
$location = "eastus"
# Create credentials, I am using one way to create credentials, there are others as well. 
# Pick one that makes the most sense according to your use case.
$vmPassword = ConvertTo-SecureString "nZ549Ux2MnW6srTvOZsq" -AsPlainText -Force
$vmCred = New-Object System.Management.Automation.PSCredential("Christian", $vmPassword)

#Create a VMSS using the default settings
New-AzVmss -Credential $vmCred -VMScaleSetName $vmssName


$diskname0 = "disk2"

New-Ay

$diskconfig = New-AzDiskConfig -Location $location -DiskSizeGB 50 -AccountType Standard_LRS -OsType Windows -CreateOption Empty -StorageAccountId
New-AzDisk -ResourceGroupName $vmssName -DiskName $diskname0 -Disk $diskconfig

$disk = Get-AzDisk -ResourceGroupName $vmssName -DiskName $diskname0
$instanceIds = Get-AzVmssVM -ResourceGroupName $vmssName -VMScaleSetName $vmssName | Select InstanceId
$vmssVm1 = Get-AzVmssVM -ResourceGroupName $vmssName -VMScaleSetName $vmssName -InstanceId $instanceIds[0].InstanceId
$vmssVm1 = Add-AzVmssVMDataDisk -VirtualMachineScaleSetVM $vmssVm1 -Lun 0 -DiskSizeInGB 50 -CreateOption Attach -StorageAccountType Standard_LRS -ManagedDiskId $disk.Id
Update-AzVmssVM -VirtualMachineScaleSetVM $vmssVm1
$vmssVm2 = Get-AzVmssVM -ResourceGroupName $vmssName -VMScaleSetName $vmssName -InstanceId $instanceIds[1].InstanceId
$vmssVm2 = Add-AzVmssVMDataDisk -VirtualMachineScaleSetVM $vmssVm2 -Lun 0 -DiskSizeInGB 50 -CreateOption Attach -StorageAccountType Standard_LRS -ManagedDiskId $disk.Id
Update-AzVmssVM -VirtualMachineScaleSetVM $vmssVm2


Get-AzVmssVM -ResourceGroupName $vmssName -VMScaleSetName $vmssName
$lb = Get-AzLoadBalancer -ResourceGroupName $vmssName -Name $vmssName
Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $lb | Select-Object Name,Protocol,FrontEndPort,BackEndPort
Get-AzPublicIpAddress -ResourceGroupName $vmssName -Name $vmssName  | Select IpAddress


# Get scale set object
$vmss = Get-AzVmss `
          -ResourceGroupName "myResourceGroup" `
          -VMScaleSetName "myScaleSet"

# Define the script for your Custom Script Extension to run
$publicSettings = @{
  "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/prepare_vm_disks.ps1");
  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File prepare_vm_disks.ps1"
}

# Use Custom Script Extension to prepare the attached data disks
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
  -Name "customScript" `
  -Publisher "Microsoft.Compute" `
  -Type "CustomScriptExtension" `
  -TypeHandlerVersion 1.8 `
  -Setting $publicSettings

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
  -ResourceGroupName "myResourceGroup" `
  -Name "myScaleSet" `
  -VirtualMachineScaleSet $vmss

  #mstsc /v 52.168.121.216:50001