$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
$resourceGroupName = "chrpap-duraupgd"
$keyVaultName = $resourceGroupName + "-kv"
$certificateName = $resourceGroupName + "-cert"
$clusterName = "chrpap-duraupgd"
$generalPassword = "PlaceholderCorp123!Corp123!"
$location = "westus"
$localCertificatePath = "D:\Certificates\"
$serviceFabricClusterDns = $clusterName + "." + $location + ".cloudapp.azure.com"

Login-AzAccount -SubscriptionId $subscriptionId
Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop

New-AzResourceGroup -Name $resourceGroupName -Location $location

Enable-AzureRmAlias
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location -EnabledForDeployment 
Import-Module ".\..\Create-GenericCluster\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -Location $location -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL


$templateFilePath = "AzureDeploy-2.json"
$parameterFilePath = "AzureDeploy.Parameters.json"
cd D:\Code\inputoutputcode\service-fabric-cluster-templates\How-To-Upgrade-Durability
cd D:\Code\FabricMonkey\FabricScripts\Upgrade-Durability

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parameterFilePath




