# Parameters
$clusterUrl = ""
$serverThumbprint = ""
$searchParameter = ""

# Connection
Connect-ServiceFabricCluster -ConnectionEndpoint $clusterUrl -ServerCertThumbprint $serverThumbprint -AzureActiveDirectory

# Filter apps by parameter
$appNames = Get-ServiceFabricApplication |  ?{ $_.ApplicationParameters.Name -contains $searchParameter } | Select ApplicationName
$nodeNames = Get-ServiceFabricNode | Select NodeName 

# Iterate over all selected instances
ForEach ($appName in $appNames)
{
    ForEach($nodeName in $nodeNames)
    {
        Try
        {
            $codePackage = Get-ServiceFabricDeployedCodePackage -NodeName $nodeName.NodeName -ApplicationName $appName.ApplicationName
            Restart-ServiceFabricDeployedCodePackage -NodeName $nodeName.NodeName -ApplicationName $appName.ApplicationName -CodePackageName $codePackage.CodePackageName -ServiceManifestName $codePackage.ServiceManifestName -CommandCompletionMode Verify
        
            Start-Sleep -Seconds 120
        }
        Catch 
        {
            Write-Host "No $appName on $nodeName"
        }
    }
}


