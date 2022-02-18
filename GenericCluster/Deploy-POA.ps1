
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$appPackageUrl = "https://chrpapblobs.blob.core.windows.net/binaries/PatchOrchestrationApplication_v1.3.2.sfpkg?sp=r&st=2020-08-05T20:31:23Z&se=2020-08-06T04:31:23Z&spr=https&sv=2019-12-12&sr=b&sig=k5MfiXa4Qqf42n3PuYaUkSpzQLxycQSvdFsIZal624Y%3D"
$deploymentName = "chrpap051400"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$resourceGroup = $deploymentName + "-group"
$armTemplate = ".\Templates\patch-orchestration-application.json"

Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

$armParameter = @{}
$armParameter.Add("appPackageUrl", $appPackageUrl)
$armParameter.Add("clusterName", $serviceFabricClusterName)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterObject $armParameter -Verbose -Mode Complete -Force

