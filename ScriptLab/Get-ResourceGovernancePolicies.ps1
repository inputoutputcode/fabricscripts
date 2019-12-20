$clusterUrl = ""
$serverThumbprint = 
Connect-ServiceFabricCluster -ConnectionEndpoint $clusterUrl -ServerCertThumbprint $serverThumbprint -AzureActiveDirectory


$allApps = Get-ServiceFabricApplication
foreach ($app in $allApps)
{
	#$app = Get-ServiceFabricApplication -ApplicationName $applicationName
	if ($app -eq $null)
	{
		Throw "Cannot find application $($ApplicationName)." 
	}
	$appParams = $app.ApplicationParameters

	$cpuParam = $appParams | where {$_.name -like "*CpuCores*"}
	$memoryParam = $appParams | where {$_.name -like "*MemoryInMB*"}

			
	Write-Host "$($app.ApplicationName) CPUCores: $($cpuParam.Value) MemoryInMB: $($memoryParam.Value)" 	
}