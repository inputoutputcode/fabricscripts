$subscriptionId = "Service Fabric Team - Temporary Testing"
$resourceGroup = "chrpap07213925-keyvault"
$alias = "chrpap"

Set-ExecutionPolicy RemoteSigned
Login-AzureRmAccount
Import-Module AzureRM.KeyVault
Import-Module AzureRM.Profile
Import-Module AzureRM.Resources
Import-Module AzureRM.Storage


\\reddog\builds\branches\git_winfab_test_tools_develop_latest\retail-amd64\bin\TempResourceManager\TempResourceManager.ps1 -action extend -resourceGroupName $resourceGroup -owner $alias -subscriptionName $subscriptionId
