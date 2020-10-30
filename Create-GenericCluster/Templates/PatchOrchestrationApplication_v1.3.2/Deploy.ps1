Param
(
    [String]
    $ApplicationPackagePath = "PatchOrchestrationApplication",

    [String]
    $ImageStoreConnectionString = "fabric:ImageStore",

    [string]
    $ApplicationVersion = "1.3.2",
	
    [hashtable]
    $ApplicationParameters = @{}
)

Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $ApplicationPackagePath -ImageStoreConnectionString $ImageStoreConnectionString
Register-ServiceFabricApplicationType PatchOrchestrationApplication
New-ServiceFabricApplication fabric:/PatchOrchestrationApplication PatchOrchestrationApplicationType $ApplicationVersion -ApplicationParameter $ApplicationParameters
