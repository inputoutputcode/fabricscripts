

$resourceGroup = "a5ahawh6he6rk-group"
$armTemplate = "patch-orchestration-application.v1.2.1.json"
$armTemplateParameters = "patch-orchestration-application.v1.2.1.parameters.json"

cd "C:\Users\Christian\Documents\Customer\adVANce\PowerShell\PatchOrchestrationApplication"

Connect-AzureRmAccount

New-AzureRmResourceGroupDeployment -Name "deploytest2" -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armTemplateParameters -Verbose -Mode Incremental

