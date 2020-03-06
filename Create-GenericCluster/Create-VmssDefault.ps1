# Common
$location = "westus";
$resourceGroupName = "chrpap-vmssdefault";

New-AzResourceGroup -Name $resourceGroupName -Location $location -Force;

# SRP
$storageName = "storage" + $resourceGroupName;
$storageType = "Standard_LRS";
New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName -Location $location -Type $storageType;
$storage = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName; 

# NRP
$subNet = New-AzVirtualNetworkSubnetConfig -Name ("subnet" + $resourceGroupName) -AddressPrefix "10.0.0.0/24";
$VNet = New-AzVirtualNetwork -Force -Name ("vnet" + $resourceGroupName) -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16" -DnsServer "10.1.1.1" -Subnet $subNet;
$VNet = Get-AzVirtualNetwork -Name ('vnet' + $resourceGroupName) -ResourceGroupName $resourceGroupName;
$SubNetId = $VNet.Subnets[0].Id;

$PubIP = New-AzPublicIpAddress -Force -Name ("PubIP" + $resourceGroupName) -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Dynamic -DomainNameLabel ("PubIP" + $resourceGroupName);
$PubIP = Get-AzPublicIpAddress -Name ("PubIP"  + $resourceGroupName) -ResourceGroupName $resourceGroupName;

# Create LoadBalancer
$FrontendName = "fe" + $resourceGroupName
$BackendAddressPoolName = "bepool" + $resourceGroupName
$ProbeName = "vmssprobe" + $resourceGroupName
$InboundNatPoolName  = "innatpool" + $resourceGroupName
$LBRuleName = "lbrule" + $resourceGroupName
$LBName = "vmsslb" + $resourceGroupName

$Frontend = New-AzLoadBalancerFrontendIpConfig -Name $FrontendName -PublicIpAddress $PubIP
$BackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $BackendAddressPoolName
$Probe = New-AzLoadBalancerProbeConfig -Name $ProbeName -RequestPath healthcheck.aspx -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2
$InboundNatPool = New-AzLoadBalancerInboundNatPoolConfig -Name $InboundNatPoolName  -FrontendIPConfigurationId `
    $Frontend.Id -Protocol Tcp -FrontendPortRangeStart 3360 -FrontendPortRangeEnd 3362 -BackendPort 3370;
$LBRule = New-AzLoadBalancerRuleConfig -Name $LBRuleName `
    -FrontendIPConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 `
    -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIP;
$ActualLb = New-AzLoadBalancer -Name $LBName -ResourceGroupName $resourceGroupName -Location $location `
    -FrontendIpConfiguration $Frontend -BackendAddressPool $BackendAddressPool `
    -Probe $Probe -LoadBalancingRule $LBRule -InboundNatPool $InboundNatPool;
$ExpectedLb = Get-AzLoadBalancer -Name $LBName -ResourceGroupName $resourceGroupName

# New VMSS Parameters
$VMSSName = "VMSS" + $resourceGroupName;

$AdminUsername = "Christian";
$AdminPassword = "nZ549Ux2MnW6srTvOZsq";

$PublisherName = "MicrosoftWindowsServer" 
$Offer         = "WindowsServer" 
$Sku           = "2012-R2-Datacenter" 
$Version       = "latest"
        
$VHDContainer = "https://" + $storageName + ".blob.core.contoso.net/" + $VMSSName;

$ExtName = "CSETest";
$Publisher = "Microsoft.Compute";
$ExtType = "BGInfo";
$ExtVer = "2.1";

#IP Config for the NIC
$IPCfg = New-AzVmssIPConfig -Name "Test" `
    -LoadBalancerInboundNatPoolsId $ExpectedLb.InboundNatPools[0].Id `
    -LoadBalancerBackendAddressPoolsId $ExpectedLb.BackendAddressPools[0].Id `
    -SubnetId $SubNetId;
            
#VMSS Config
$VMSS = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_A2" -UpgradePolicyMode "Automatic" `
    | Add-AzVmssNetworkInterfaceConfiguration -Name "Test" -Primary $True -IPConfiguration $IPCfg `
    | Add-AzVmssNetworkInterfaceConfiguration -Name "Test2"  -IPConfiguration $IPCfg `
    | Set-AzVmssOSProfile -ComputerNamePrefix "Test" -AdminUsername $AdminUsername -AdminPassword $AdminPassword `
    | Set-AzVmssStorageProfile -Name "Test" -OsDiskCreateOption 'FromImage' -OsDiskCaching "None" `
    -ImageReferenceOffer $Offer -ImageReferenceSku $Sku -ImageReferenceVersion $Version `
    -ImageReferencePublisher $PublisherName -VhdContainer $VHDContainer `
    | Add-AzVmssExtension -Name $ExtName -Publisher $Publisher -Type $ExtType -TypeHandlerVersion $ExtVer -AutoUpgradeMinorVersion $True

#Create the VMSS
New-AzVmss -ResourceGroupName $resourceGroupName -Name $VMSSName -VirtualMachineScaleSet $VMSS;