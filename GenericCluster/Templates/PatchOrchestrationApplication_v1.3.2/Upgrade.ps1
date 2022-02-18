Param
(
    [String]
    $ApplicationPackagePath = "PatchOrchestrationApplication",

    [String]
    $ImageStoreConnectionString = "fabric:ImageStore",

    [string]
    $ApplicationVersion = "1.3.2",
	
    [hashtable]
    $ApplicationParameters = @{},

    [string]
    $ApplicationInstanceName = "fabric:/PatchOrchestrationApplication"
)

Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $ApplicationPackagePath -ImageStoreConnectionString $ImageStoreConnectionString
Register-ServiceFabricApplicationType PatchOrchestrationApplication
Start-ServiceFabricApplicationUpgrade -ApplicationName $ApplicationInstanceName -ApplicationTypeVersion $ApplicationVersion -FailureAction Rollback -Monitored -ApplicationParameter $ApplicationParameters
