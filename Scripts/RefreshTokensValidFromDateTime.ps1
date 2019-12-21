#parameter
param([Parameter(Mandatory=$True, HelpMessage="Location of the input csv file. Example c:\input.csv")][string]$inputPath,
[Parameter(Mandatory=$True, HelpMessage="Location of the output csv file. Example c:\output.csv")][string]$ouputPath)

#Azure signIn
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
Connect-AzureAD -Confirm
Write-Host "Authentication successful." -foreground "green"

#read on UPN list from csv file
$upns = Import-Csv $inputPath | select -ExpandProperty "UPN"

$csvContents = @()
$count = $upns.Count 
$counter = 0

#iterate UPNs and read RefreshTokenValidFromDateTime value from Azure AD
foreach($upn in $upns)
{
    #show progress
    Write-Progress -Activity "Iterating over list of UPNs. Requesting AzureAD data for account $upn, number $counter of $count" -percentComplete ($counter/$count*100)

    $row = New-Object System.Object

    #RefreshTokensValidFromDateTime
    $currentUser = Get-AzureADUser -ObjectID $upn | Select UserPrincipalName, RefreshTokensValidFromDateTime

    $row | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $currentUser.UserPrincipalName
    $row | Add-Member -MemberType NoteProperty -Name "RefreshTokensValidFromDateTime" -Value $currentUser.RefreshTokensValidFromDateTime

    #Group Memberships
    $groupmemberships = Get-AzureADUserMembership -All $true -ObjectId $upn | Sort-Object -Property DisplayName

    $row | Add-Member -MemberType NoteProperty -Name "GroupMemberships" -Value ($groupmemberships.DisplayName -Join ", ")

    $csvContents += $row
    $counter++
}

#save output
$csvContents | Export-CSV -Path $ouputPath -Delimiter ";" -NoTypeInformation
Write-Host "Output file saved." -foreground "green" 