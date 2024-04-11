
##Create and deploy resource group for network.json file
##New-AzResourceGroup -Name "ArmTemplateTest" -Location "East US"
##New-AzResourceGroupDeployment -ResourceGroupName "ArmTemplateTest" -TemplateFile "../../fork/service-fabric-api-management/network.json" -TemplateParameterFile "../../fork/service-fabric-api-management/network.parameters.json" -Force


##Do the same for the cluster.json file. 
##For this one you have to copy over some script lines to do the cert creation 
##(create Key Vault resource, create self-signed cert, upload the cert to Key Vault, getting reference values for the cert). 
##You also want to add the parameters or parameter file for your cluster.json. 

#Declare Parameters:
$azureRegion = "eastus"
$localCertificatePath = "C:\Certificates\"
$generalPassword = "nZsa74xcvWX2Zsq"
$currentExecutionPath = "C:\FabricScripts\GenericCluster"
$armTemplate = "../../fork/service-fabric-api-management/cluster.json"
$armParameter = "../../fork/service-fabric-api-management/cluster.parameters.json"

## COPR subscription (Service Fabric - Temporary Testing)
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f" 
Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}

## Generate unique id strings
$deploymentName = "millieo" + (Get-Date).ToString("ddHHmm")

# Define dynamic parameters
$certificateName = $deploymentName + "-cert"
$proxyCertificateName = $deploymentName + "-proxycert"
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$serviceFabricClusterName = $deploymentName + "-servicefabric"
$serviceFabricClusterDns = $serviceFabricClusterName + "." + $azureRegion + ".cloudapp.azure.com"
$omsName = $deploymentName + "-oms"


New-AzResourceGroup -Name $resourceGroup -Location $azureRegion

New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment 
Import-Module ".\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
New-Item -ItemType Directory -Path $localCertificatePath -ErrorAction Ignore
$clusterCertificate = Invoke-AddCertToKeyVaultAsSecret -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroup -Location $azureRegion -VaultName $keyVaultName -CertificateName $certificateName -CreateSelfSignedCertificate -DnsName $serviceFabricClusterDns -OutputPath $localCertificatePath -Password $generalPassword
$clusterCertificate.CertificateThumbprint
$clusterCertificate.SourceVault
$clusterCertificate.CertificateURL

## Deploy Azure Service Fabric Cluster
#$armParameter = @{}
#$armParameter.Add("deploymentId", $deploymentName)
#$armParameter.Add("clusterDNSname", $serviceFabricClusterDns)
#$armParameter.Add("computeLocation", $azureRegion)
#$armParameter.Add("clusterName", $serviceFabricClusterName)
#$armParameter.Add("adminPassword", $generalPassword)
#$armParameter.Add("sourceVaultValue", $clusterCertificate.SourceVault)
#$armParameter.Add("certificateUrlValue", $clusterCertificate.CertificateURL)
#$armParameter.Add("certificateThumbprint", $clusterCertificate.CertificateThumbprint)

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armParameter -Verbose -ErrorAction Stop

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -TemplateParameterFile $armParameter -Verbose -Mode Incremental

##New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile "../../fork/service-fabric-api-management/cluster.json" -TemplateParameterFile "../../fork/service-fabric-api-management/cluster.parameters.json" -Force

