

$resourceGroup = "chrpap271653-servicefabric"
$armTemplate = "service-fabric-observer.json"
$armTemplateParameters = "service-fabric-observe.v3.1.20.parameters.json"

cd "C:\Users\Christian\Documents\Customer\adVANce\PowerShell\PatchOrchestrationApplication"

Connect-AzureRmAccount

New-AzureRmResourceGroupDeployment -Name "deploy-service-fabric-observer" -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armTemplateParameters -Verbose -Mode Incremental

