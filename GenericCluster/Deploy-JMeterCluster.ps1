cd D:\Code\jmeter-distributed-test-harness\templates

$resourceGroup = "jmetertesting"
$azureRegion = "westeurope"
$armTemplate = "azuredeploy.json"
$armParameterTemplate = "azuredeploy.parameters.json"

New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force 
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armParameterTemplate -Verbose -Mode Incremental
