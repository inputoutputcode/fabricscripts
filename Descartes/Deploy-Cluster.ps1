
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$location = "East US2"
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")
$resourceGroup = $deploymentName + "group"

$currentExecutionPath = "D:\Code\FabricMonkey\FabricScripts\Descartes"
cd $currentExecutionPath

Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

Enable-AzureRmAlias
New-AzResourceGroup -Name $resourceGroup -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile azuredeploy.json -TemplateParameterFile azuredeploy.parameters.json -Verbose



$serverThumbprint = "487D86424B42B446AF460CC6493BDD7B49CD1AE2"

# get brain endpoint from cluster manifest in SFX
$connectionEndpoint = "52.251.18.47:19900/brain_nzdaq24ihn5uo"
Connect-ServiceFabricCluster -ConnectionEndpoint $connectionEndpoint -KeepAliveIntervalInSec 10 `
      -X509Credential `
      -ServerCertThumbprint $serverThumbprint  `
      -FindType FindByThumbprint `
      -FindValue $clientThumprint `
      -StoreLocation CurrentUser `
      -StoreName My
