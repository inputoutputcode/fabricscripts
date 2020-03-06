Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az -AllowClobber -Scope AllUsers -Force
Login-AzAccount -Identity
Select-AzSubscription -Subscription "Service Fabric Team - Temporary Testing"

$resourceGroupName = "chrpapvmss"
$storageAccountName = "chrpapvmssstorage"
$fileShareName = "chrpapshare"
$desiredDriveLetter= "Y"
$serviceAccountUsername = "Christian"
$serviceAccountPassword = "nZ549Ux2MnW6srTvOZsq"

# These commands require you to be logged into your Azure account, run Login-AzAccount if you haven't
# already logged in.
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName

# The cmdkey utility is a command-line (rather than PowerShell) tool. We use Invoke-Expression to allow us to 
# consume the appropriate values from the storage account variables. The value given to the add parameter of the
# cmdkey utility is the host address for the storage account, <storage-account>.file.core.windows.net for Azure 
# Public Regions. $storageAccount.Context.FileEndpoint is used because non-Public Azure regions, such as sovereign 
# clouds or Azure Stack deployments, will have different hosts for Azure file shares (and other storage resources).
Invoke-Expression -Command ("cmdkey /add:$([System.Uri]::new($storageAccount.Context.FileEndPoint).Host) " + `
    "/user:AZURE\$($storageAccount.StorageAccountName) /pass:$($storageAccountKeys[0].Value)")


# Store the credentials for another user
$password = ConvertTo-SecureString -String $serviceAccountPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $serviceAccountUsername, $password
Start-Process -FilePath PowerShell.exe -Credential $credential -LoadUserProfile


# These commands require you to be logged into your Azure account, run Login-AzAccount if you haven't
# already logged in.
$fileShare = Get-AzStorageShare -Context $storageAccount.Context | Where-Object { 
    $_.Name -eq $fileShareName -and $_.IsSnapshot -eq $false
}

if ($fileShare -eq $null) {
    throw [System.Exception]::new("Azure file share not found")
}

# The value given to the root parameter of the New-PSDrive cmdlet is the host address for the storage account, 
# <storage-account>.file.core.windows.net for Azure Public Regions. $fileShare.StorageUri.PrimaryUri.Host is 
# used because non-Public Azure regions, such as sovereign clouds or Azure Stack deployments, will have different 
# hosts for Azure file shares (and other storage resources).
$password = ConvertTo-SecureString -String $storageAccountKeys[0].Value -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$($storageAccount.StorageAccountName)", $password
$fileSharePath = "\\$($fileShare.StorageUri.PrimaryUri.Host)\$($fileShare.Name)"
New-PSDrive -Name $desiredDriveLetter -PSProvider FileSystem -Root $fileSharePath -Credential $credential -Persist




$connectTestResult = Test-NetConnection -ComputerName chrpapvmssstorage.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"chrpapvmssstorage.file.core.windows.net`" /user:`"Azure\chrpapvmssstorage`" /pass:`"BbpS4fqDQGszgQ0ULyhzgf+ySLL449G285izsByOaFS5lGgzyrSLHYQM4FVCwuqNiRLQR6E+zegxgzsxbOsF9Q==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\chrpapvmssstorage.file.core.windows.net\chrpapshare"-Persist
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
