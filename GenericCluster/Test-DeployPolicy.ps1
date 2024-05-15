

$subscriptionId = "d715466f-2653-406f-be2f-495f7fd4e1b7" 
$tenant = "7459bed2-8ead-4b9b-84ff-38402c19a97d"

Try 
{
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
} 
Catch 
{ 
    Connect-AzAccount -Tenant $tenant -SubscriptionId $subscriptionId 
    Set-AzContext -SubscriptionId $subscriptionId -Name MSDN
}

Get-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop

Disconnect-AzAccount

Remove-AzContext
Get-AzContext -ListAvailable


(Get-AzPolicyAlias -NamespaceMatch 'Microsoft.Resources').Aliases | Select Name

(Get-AzPolicyAlias -AliasMatch 'managedBy').Aliases

## Remove it
Get-AzPolicyAssignment | Remove-AzPolicyAssignment 
Get-AzPolicyDefinition | Where-Object { $_.Name.StartsWith("SF-") } | Remove-AzPolicyDefinition -Force


## Remove it via REST API, not tested
$azSubcriptions = Get-AzSubscription -tenantid '## Your TenantID ##'

$PolicyAssignmentNameNotLike = "ASC Default*"

Foreach($azSubcription in $azSubcriptions){

    Write-verbose "RUN : Subscription : $($azSubcription.name)" -Verbose

    $azPolicyAssignments = ((Invoke-AzRestMethod -uri "https://management.azure.com/subscriptions/$($azSubcription.id)/providers/Microsoft.Authorization/policyAssignments?api-version=2022-06-01").content | convertfrom-json).value

    Foreach($azPolicyAssignment in $azPolicyAssignments.where{$_.properties.displayName -notlike $PolicyAssignmentNameNotLike}){

        Write-verbose "DELETE PolicyAssignment : $($azPolicyAssignment.properties.displayName)" -verbose

        $webrequest = Invoke-AzRestMethod -method DELETE -uri "https://management.azure.com/subscriptions/$($azSubcription.id)/providers/Microsoft.Authorization/policyAssignments/$($azPolicyAssignment.name)?api-version=2022-06-01"

        if($webrequest.StatusCode -eq 200){
            Write-verbose "Suceeded to Delete Policy Assignment: $($azPolicyAssignment.name)"
        } else {
            Write-Error "Failed to Delete Policy Assignment: $($azPolicyAssignment.name)"
        }
    }

}

