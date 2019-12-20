
$resourceGroup = "zo3elo2i3rv5u-group"
$armTemplate = "patch-orchestration-application.v1.2.2.json"
$armTemplateParameters = "patch-orchestration-application.v1.2.2.parameters.json"

cd "C:\Users\Christian\Documents\Customer\adVANce\PowerShell\PatchOrchestrationApplication"

Connect-AzureRmAccount

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armTemplateParameters -Verbose -Mode Incremental
