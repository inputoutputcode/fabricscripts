Login-AzAccount
$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"
Set-AzContext -SubscriptionId $subscriptionId
Set-AzVmss -ResourceGroup "chrpap201420group" -VMScaleSetName "mngmt" -InstanceId "1" -Reimage -Debug
Get-InstalledModule -Name "Az*"
Get-InstalledModule -Name "Az.Compute*"
Get-InstalledModule -Name Az -AllVersions | Select-Object -Property Name, Version
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Install-Module -Name Az
$PSVersionTable.PSVersion