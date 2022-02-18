Connect-ServiceFabricCluster

$configOverride = New-Object -TypeName System.Fabric.Description.ConfigParameterOverride(
    "EseStore",
    "EnableFastCompressionMode",
    "True")
$configOverrideList = New-Object 'System.Collections.Generic.List[System.Fabric.Description.ConfigParameterOverride]'
$configOverrideList.Add($configOverride)
Add-ServiceFabricConfigurationParameterOverrides -NodeName _Node_1 -ConfigParameterOverrideList $configOverrideList -Verbose -Force



Get-ServiceFabricNodeConfiguration | Out-File clusterManifest1.xml


Update-ServiceFabricNodeConfiguration -ClusterManifestPath C:\Users\chrpap\clusterManifest1.xml -Force -Verbose