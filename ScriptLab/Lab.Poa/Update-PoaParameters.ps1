
$clusterEndpoint = "zo3elo2i3rv5u-servicefabric.westeurope.cloudapp.azure.com:19000"
$certificateThumbprint = "‎52198C1CD5D726103F41BAF4A23F30B2F819EDC3"

Connect-ServiceFabricCluster -ConnectionEndpoint $clusterEndpoint -ServerCertThumbprint $certificateThumbprint

Import-Module -Name "C:\Users\Christian\Documents\Customer\adVANce\PowerShell\ServiceFabricHelpers" -Verbose

$appName = "fabric:/PatchOrchestrationApplication"
UpgradeServiceFabricService -ApplicationName $appName -ParameterName "WUOperationTimeOutInMinutes" -ParameterValue "300" -Monitored:$False
UpgradeServiceFabricService -ApplicationName $appName -ParameterName "TaskApprovalPolicy" -ParameterValue "UpgradeDomainWise" -Monitored:$False
 
 