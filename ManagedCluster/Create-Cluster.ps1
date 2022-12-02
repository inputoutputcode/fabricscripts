cd C:\Code\FabricScripts\ManagedCluster

New-Item -ItemType Directory sfmcClients | Out-Null
cd sfmcClients
Invoke-WebRequest -Uri "https://github.com/a-santamaria/ServiceFabricManagedClustersClients/blob/master/AzPowershellClient/LoadModules.ps1?raw=true" -OutFile LoadModules.ps1
.\LoadModules.ps1

cd sfmcClients
.\LoadModules.ps1 -DownloadLatest



Login-AzAccount
Set-AzContext -SubscriptionId "13ad2c84-84fa-4798-ad71-e70c07af873f"

$resourceGroup = "chrpapmngsf4"
$location = "EastUS2" 

New-AzResourceGroup -Name $resourceGroup -Location $location

$clusterName = "chrpapmngsfcl4" 
$password = "Password4321!@#" | ConvertTo-SecureString -AsPlainText -Force
$thumbprint = "ae968f24a00357481f5b3effb6d352188a8c6e7b"
$clusterSku = "Standard"

New-AzServiceFabricManagedCluster -ResourceGroupName $resourceGroup -Location $location -ClusterName $clusterName -ClientCertThumbprint $thumbprint -ClientCertIsAdmin -AdminPassword $password -Sku $clusterSKU -Verbose

$nodeType1Name = "NT1" 
New-AzServiceFabricManagedNodeType -ResourceGroupName $resourceGroup -ClusterName $clusterName -Name $nodeType1Name -Primary -InstanceCount 5


