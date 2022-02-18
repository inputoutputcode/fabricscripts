Param
(
    [String]
    $ImageStoreConnectionString = "fabric:ImageStore",

    [string]
    $ApplicationVersion = "1.3.2"
)

Remove-ServiceFabricApplication -ApplicationName fabric:/PatchOrchestrationApplication -Force
Unregister-ServiceFabricApplicationType -ApplicationTypeName PatchOrchestrationApplicationType -ApplicationTypeVersion $ApplicationVersion -Force
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore PatchOrchestrationApplication -ImageStoreConnectionString $ImageStoreConnectionString