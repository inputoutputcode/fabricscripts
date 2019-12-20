
$applicationNames = Get-ServiceFabricApplication | Select ApplicationName, ApplicationTypeName, ApplicationTypeVersion
$exceptApplicationNames = @("fabric:/PatchOrchestrationApplication", "fabric:/Watchdog")

ForEach ($applicationName in $applicationNames)
{
    if ($exceptApplicationNames -notcontains $applicationName.ApplicationName.OriginalString)
    {
        # Remove an application instance
        Remove-ServiceFabricApplication -ApplicationName $applicationName.ApplicationName.OriginalString -Force
    }   
}



# Unregister the application type
#Unregister-ServiceFabricApplicationType -ApplicationTypeName MyApplicationType -ApplicationTypeVersion 1.0.0


$applicationTypes = Get-ServiceFabricApplicationType | Select ApplicationTypeName, ApplicationTypeVersion
$exceptApplicationTypes = @("PatchOrchestrationApplicationType", "WatchdogType")
ForEach ($applicationType in $applicationTypes)
{
    if ($exceptApplicationTypes -notcontains $applicationType.ApplicationTypeName)
    {
        $typeName = $applicationType.ApplicationTypeName
        $typeVersion = $applicationType.ApplicationTypeVersion

        # Unregister the application type
        Unregister-ServiceFabricApplicationType -ApplicationTypeName $typeName -ApplicationTypeVersion $typeVersion -Force
    }   
}
