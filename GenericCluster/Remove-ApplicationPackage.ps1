Connect-ServiceFabricCluster

# Remove an service instance
$serviceName = "fabric:/Vortex.Backend.Session/ClientActorService"
$serviceName = "fabric:/Vortex.Backend.Session/ReceiptActorService"
Remove-ServiceFabricService -ServiceName $serviceName -Force

# Remove an application instance
$applicationName = "fabric:/Vortex.Backend.Session"
Remove-ServiceFabricApplication -ApplicationName $applicationName -Force

# Unregister the application type
$applicationType = "Vortex.Backend.Session"
$version = "1.0.0"
Unregister-ServiceFabricApplicationType -ApplicationTypeName $applicationType -ApplicationTypeVersion $version -Force
