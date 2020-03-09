
$storageAccountName
$storageAccountHostUri
$storageAccountKey
$serviceAccountUsername
$serviceAccountPassword
$fileShareEndpoint
$fileSharePath


# Save the password so the drive will persist on reboot
Invoke-Expression -Command ("cmdkey /add:$fileShareEndpoint /user:AZURE\$($storageAccountName) /pass:$($storageAccountKey)")

# Store the credentials for another user
$password = ConvertTo-SecureString -String $serviceAccountPassword -AsPlainText -Force
$credentialUser = New-Object System.Management.Automation.PSCredential -ArgumentList $serviceAccountUsername, $password
Start-Process -FilePath PowerShell.exe -Credential $credentialUser -LoadUserProfile

# The value given to the root parameter of the New-PSDrive cmdlet is the host address for the storage account, 
# <storage-account>.file.core.windows.net for Azure Public Regions. $fileShare.StorageUri.PrimaryUri.Host is 
# used because non-Public Azure regions, such as sovereign clouds or Azure Stack deployments, will have different 
# hosts for Azure file shares (and other storage resources).
$storageKey = ConvertTo-SecureString -String $storageAccountKey -AsPlainText -Force
$credentialStorage = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$($storageAccountName)", $storageKey
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $fileSharePath -Credential $credentialStorage -Persist

$connectTestResult = Test-NetConnection -ComputerName chrpap071314fileshare.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root $fileSharePath-Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}





$password = ConvertTo-SecureString -String "BbpS4fqDQGszgQ0ULyhzgf+ySLL449G285izsByOaFS5lGgzyrSLHYQM4FVCwuqNiRLQR6E+zegxgzsxbOsF9Q==" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\chrpapvmssstorage", $password
New-PSDrive -Name "Y" -PSProvider FileSystem -Root "\\chrpapvmssstorage.file.core.windows.net\chrpapshare" -Credential $credential -Persist



$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token
(Invoke-WebRequest -Uri https://management.azure.com/subscriptions/13ad2c84-84fa-4798-ad71-e70c07af873f/resourceGroups/chrpapvmss?api-version=2016-06-01 -Method GET -ContentType "application/json" -Headers @{ Authorization ="Bearer $ArmToken"}).content
