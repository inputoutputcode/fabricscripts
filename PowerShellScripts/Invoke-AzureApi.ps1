<#
Here is the function I am using to get the bearer token of my user from the CorpDir tenant.
I first connect to Azure using the following command from PS shell:
#>

Connect-AzureRmAccount -Subscription bc7b738d-ea2e-4548-bdb3-a27b59cc6762

<#
Then I define this function:
#>

function Get-AzureRmCachedAccessToken()
{
    $ErrorActionPreference = 'Stop'
  
    if(-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    } else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
  
    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    $token.AccessToken
}

<#
Finally, I run the following code to get the bearer token copied into the clipboard:
#>

('Bearer {0}' -f (Get-AzureRmCachedAccessToken)) | Set-Clipboard

$token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik4tbEMwbi05REFMcXdodUhZbkhRNjNHZUNYYyIsImtpZCI6Ik4tbEMwbi05REFMcXdodUhZbkhRNjNHZUNYYyJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuY29yZS53aW5kb3dzLm5ldC8iLCJpc3MiOiJodHRwczovL3N0cy53aW
5kb3dzLm5ldC85NjUyZDdjMi0xY2NmLTQ5NDAtODE1MS00YTkyYmQ0NzRlZDAvIiwiaWF0IjoxNTU0NzMyNzQ2LCJuYmYiOjE1NTQ3MzI3NDYsImV4cCI6MTU1NDczNjY0NiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhMQUFBQXhOWXZrNE12QjdjWmpVa21SeUlJdkZSL3dITE5jaHJldFlyQ2tBU
Wx3djFlYmwyRGU0OGJDK1hUdWJicHJBLzVCbUhaeGRRT3NoRFlNY3RUZTI4ZEFrcko4aUJDSklDVm40QVREQjFqU2w4PSIsImFtciI6WyJwd2QiLCJtZmEiXSwiYXBwaWQiOiIxOTUwYTI1OC0yMjdiLTRlMzEtYTljZi03MTc0OTU5NDVmYzIiLCJhcHBpZGFjciI6IjAiLCJkZXZpY2VpZCI6ImRh
YWRjNmI1LWNkNTMtNDEyZS05NDczLTUyNDQzYWFiOWE0NCIsImdyb3VwcyI6WyI1OWJhN2I1NC0yMDJjLTRhMWQtYTZjMi1iZDdjODdlMzMyZTEiLCJlZThlMGNkNC1mNjk2LTQ5OTctOTk2OC0wNTRiMTlhNTNiZWIiLCIwYTI4NGExYy01N2E2LTRmNjMtOGE5OS1kNDQzYWIwMGZlMWEiLCIzMGF
kNWMwNi04N2Y0LTRhYTktOTJlNC1jNDcxNGFkMzgyOGIiLCI3Yjc0ZjhmOC01YTY5LTQzM2ItYjY1MC0wYTc1MDAzMmRlNDAiLCJmMTkyNjg1OS1lODk4LTRlNTUtOThkZS1hMjFiZGEyZmQzMWUiLCI4ZWRlM2IyOS05ZDEzLTQzMDUtODA1OS01ODNmNThlZTJkYTEiLCI5YWY3YWM0NS1iZDRmLT
Q5MTQtODdhOS1hYTNlM2U0ZGQ1YTEiLCJhNDcwYWFhMi05ODRjLTQ5NmItODdhNS0yYmZhYTI2ZjViZmIiXSwiaXBhZGRyIjoiODAuMTg3LjEyMy4xNTYiLCJuYW1lIjoiQ1NUWF9hX0NIUEFQUEUiLCJvaWQiOiJhMDhkNjAwYy04YmQwLTRmODAtOGQ2Zi1kZGQ1ZDk0N2MxN2QiLCJwdWlkIjoiM
TAwM0JGRkRBQjJERDAzQyIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IlZaYUZLQ3RvQ0FaMGxSQkwwWGU1U0FYSzhhMzlMcW16cGE5bnVQNlFURHMiLCJ0aWQiOiI5NjUyZDdjMi0xY2NmLTQ5NDAtODE1MS00YTkyYmQ0NzRlZDAiLCJ1bmlxdWVfbmFtZSI6IkNTVFhfYV9DSFBB
UFBFQGNvcnBkaXIub25taWNyb3NvZnQuY29tIiwidXBuIjoiQ1NUWF9hX0NIUEFQUEVAY29ycGRpci5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJYeXhvLU1qaDlFLWVUR2RaNlBNNEFBIiwidmVyIjoiMS4wIn0.P6x881kKqwU1K21OBDDrEB3qDysSU3bh-wDiUWoa4fASwYCyEr9sTXpWFO_eYN2
X8NrneiwWCHROwmZU9iqsCX6rivB0_7JmQ-P8L0Neq0lRqTnVbFVt32606m2N4I0fkr8HzuW_cDhWRRPIoC65ZV5Ps63eID0O579H4jdz6fvWp_g4S7pteufQAzOziToYvJ0iiHzM_8_J5bwTa5X9i-ASdMpDFyI23SwsEbZtZaQBmkRVI0L-BiWIxr7V0TmTgkMqcshjl-tVyYYzUsc_ESwrR7UkHO
pkIOFsU64sHqZ0dRZkK4dlLBQrmszxl49kz8TwI16uu3LjmpiEwjGbwg"
$Script:Headers = @{
        "Authorization" = "Bearer " + $token
    }

    
function Invoke-AzureApi {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Method, 
        [Parameter(Mandatory = $true)]
        [string]$Uri, 
        [string]$ContentType = "application/json",
        [string]$ApiVersion = "2018-01-01"
    )

   
    Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Script:Headers -Body $Body -ContentType $ContentType
}
