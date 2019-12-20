# Deprovisioning POA

$clusterEndpoint = "a5ahawh6he6rk-servicefabric.westeurope.cloudapp.azure.com:19000"
$clusterCertificateThumbprint = "B57BA4BF7BBEA6A9049B397ED03A6957CCEE1739"

Connect-ServiceFabricCluster -ConnectionEndpoint $clusterEndpoint `
    -KeepAliveIntervalInSec 10 `
    -X509Credential -ServerCertThumbprint $clusterCertificateThumbprint `
    -FindType FindByThumbprint -FindValue $clusterCertificateThumbprint `
    -StoreLocation CurrentUser -StoreName My

$applicationName = "PatchOrchestrationApplicationType"

$serviceName = "fabric:/$applicationName/CoordinatorService"
Remove-ServiceFabricService -ServiceName $serviceName -Force

$serviceName = "fabric:/$applicationName/NodeAgentService"
Remove-ServiceFabricService -ServiceName $serviceName -Force

# Remove an application instance
$applicationName = "fabric:/$applicationName"
Remove-ServiceFabricApplication -ApplicationName $applicationName -Force

# Unregister the application type
$applicationType = "Vortex.Backend.Session"
$version = "1.0.0"
Unregister-ServiceFabricApplicationType -ApplicationTypeName $applicationType -ApplicationTypeVersion $version -Force
