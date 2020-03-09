Enable-AzureRmAlias

Get-AzSubscription | Select Name, SubscriptionId
## 13ad2c84-84fa-4798-ad71-e70c07af873f
Select-AzSubscription -Subscription "Service Fabric Team - Temporary Testing"

$resourceGroupName = "chrpap00-vmssgame"
$scaleSetName = "mgmt"
$location = "westus"

New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzVirtualNetworkSubnetConfig `
  -Name subnetOne `
  -AddressPrefix 10.0.0.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name vnet `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $frontendSubnet

$pip = New-AzPublicIpAddress `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -Name pip `
  -Sku Standard

$frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "frontenPool" `
  -PublicIpAddress $pip

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name "myBackEndPool"

$lb = New-AzLoadBalancer `
  -ResourceGroupName $resourceGroupName `
  -Name "lb" `
  -Location $location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Sku Standard 

Add-AzLoadBalancerProbeConfig `
  -Name "healthProbe" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

Set-AzLoadBalancer -LoadBalancer $lb

$probe = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "healthProbe"

$rule = Add-AzLoadBalancerRuleConfig `
  -Name "loadBalancerRule" `
  -LoadBalancer $lb `
  -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

Set-AzLoadBalancer -LoadBalancer $lb

$userName = "Christian"
$passWord = ConvertTo-SecureString -String "nZ549Ux2MnW6srTvOZsq" -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $passWord

New-AzVmss `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -VMScaleSetName $scaleSetName `
  -VirtualNetworkName "vnet" `
  -SubnetName "subnetOne" `
  -PublicIpAddressName "pip" `
  -LoadBalancerName "lb" `
  -UpgradePolicyMode "Automatic" `
  -VmSize "Standard_A0" `
  -InstanceCount 2 `
  -ImageName Win2016Datacenter `
  -SinglePlacementGroup `
  -Credential $credentials `
  -Debug -Verbose

$publisherName = "MicrosoftWindowsServer" 
$offer         = "WindowsServer" 
$sku           = "2012-R2-Datacenter" 
$version       = "latest"

$vmss = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_A2" -UpgradePolicyMode "Automatic" `
        | Add-AzVmssNetworkInterfaceConfiguration -Name "Test" -Primary $True -IPConfiguration $IPCfg `
        | Add-AzVmssNetworkInterfaceConfiguration -Name "Test2" -IPConfiguration $IPCfg `
        | Set-AzVmssOSProfile -ComputerNamePrefix "Test" -AdminUsername $userName -AdminPassword $passWord `
        | Set-AzVmssStorageProfile -Name "Test" -OsDiskCreateOption 'FromImage' -OsDiskCaching "None" `
        -ImageReferenceOffer $offer -ImageReferenceSku $sku -ImageReferenceVersion $version `
        -ImageReferencePublisher $publisherName -VhdContainer $vhdContainer 
#    | Add-AzVmssExtension -Name $extName -Publisher $publisher -Type $extType -TypeHandlerVersion $extVer -AutoUpgradeMinorVersion $True

New-AzVmss -ResourceGroupName $resourceGroup -Name $scalesetName -VirtualMachineScaleSet $vmss

$vmss = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_A0" -UpgradePolicyMode "Automatic"

$disk = Get-AzDisk -ResourceGroupName $rgname -DiskName $diskname0
$VmssVM = Get-AzVmssVM -ResourceGroupName "myrg" -VMScaleSetName "myvmss" -InstanceId 0
$VmssVM = Add-AzVmssVMDataDisk -VirtualMachineScaleSetVM $VmssVM -Lun 0 -DiskSizeInGB 10 -CreateOption Attach -StorageAccountType Standard_LRS -ManagedDiskId $disk.Id
Update-AzVmssVM -VirtualMachineScaleSetVM $VmssVM