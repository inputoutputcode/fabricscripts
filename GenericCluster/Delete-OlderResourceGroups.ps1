$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"


Try {
  Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} Catch {
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
}



$days = 1
$pointInTime = [DateTime]::Now.AddHours(-$days);
$horizon = $pointInTime.AddDays(-$days);

"===Removing resource groups created between $horizon and $pointInTime==="

# Get potential log entries
$logs = @()
$logs += Get-AzureRmLog -StartTime $horizon -EndTime $pointInTime -Status "Succeeded" -ResourceProvider "Microsoft.Resources" -WarningAction "SilentlyContinue" `
    | Select-Object ResourceGroupName, ResourceId, @{Name="EventNameValue"; Expression={$_.EventName.Value}}, @{Name="OperationNameValue"; Expression={$_.OperationName.Value}}, EventTimestamp, @{Name="HttpVerb"; Expression={$_.HttpRequest.Method}} `
    | Where-Object -FilterScript {$_.EventNameValue -EQ "EndRequest" -and $_.OperationNameValue -eq "Microsoft.Resources/subscriptions/resourcegroups/write" -and $_.HttpVerb -eq "PUT"} `
    | Select-Object -ExpandProperty ResourceGroupName -Unique

"Expired resource groups (created BEFORE $pointInTime) -> $logs"

# Get recent log entries to remove from the list
$nologs = @()
$nologs += Get-AzureRmLog -StartTime $pointInTime -Status "Succeeded" -ResourceProvider "Microsoft.Resources" -WarningAction "SilentlyContinue" `
| Select-Object ResourceGroupName, ResourceId, @{Name="EventNameValue"; Expression={$_.EventName.Value}}, @{Name="OperationNameValue"; Expression={$_.OperationName.Value}}, EventTimestamp, @{Name="HttpVerb"; Expression={$_.HttpRequest.Method}} `
| Where-Object -FilterScript {$_.EventNameValue -EQ "EndRequest" -and $_.OperationNameValue -eq "Microsoft.Resources/subscriptions/resourcegroups/write" -and $_.HttpVerb -eq "PUT"} `
| Select-Object -ExpandProperty ResourceGroupName -Unique

"Resource groups created AFTER $pointInTime -> $nologs"

# remove any that were found to have recent creation
$rgs = $logs | Where-Object {$nologs -notcontains $_} | Select-Object @{Name="ResourceGroupName"; Expression={$_}} | Get-AzureRmResourceGroup -ErrorAction "SilentlyContinue"

"Existing resource groups to delete -> $($rgs | Select-Object -ExpandProperty ResourceGroupName)"

$rgs | Remove-AzureRmResourceGroup -Force -AsJob