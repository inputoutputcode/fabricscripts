# https://learn.microsoft.com/en-us/azure/service-fabric/quickstart-cluster-bicep?tabs=CLI

# Sign in to your Azure account
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
Login-AzAccount -SubscriptionId $subscriptionId

# Designate unique (within cloudapp.azure.com) names for your resources
$resourceGroupName = "chrpap-bicep-group"
$keyVaultName = "chrpapbicepkeyvault"
$clustername = "chrpapbicepquickstart"

# Create a new resource group for your Key Vault and Service Fabric cluster
New-AzResourceGroup -Name $resourceGroupName -Location SouthCentralUS

# Create a Key Vault enabled for deployment
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location SouthCentralUS -EnabledForDeployment

$password = "Corp123!Corp123!"
$certDNSName = "$clustername.southcentralus.cloudapp.azure.com"
$keyVaultSecretName = "chrpapbicepsecretname"

cd D:\Code\FabricMonkey\FabricScripts\bicep\biceps-docs
.\New-ServiceFabricClusterCertificate.ps1 -Password $password -CertDNSName $certDNSName -KeyVaultName $keyVaultName -KeyVaultSecretName $keyVaultSecretName

$templateFilePath = "main.bicep"
$parameterFilePath = "azuredeploy.parameters.json"

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parameterFilePath -Verbose
