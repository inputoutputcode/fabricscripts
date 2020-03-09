param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $fileShareStorageAccountName,

    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
    [System.String]
    $fileShareStorageAccountKey,

    [Parameter(Mandatory=$True, Position=3, ValueFromPipeline=$false)]
    [System.String]
    $fileShareEndpoint,

    [Parameter(Mandatory=$True, Position=4, ValueFromPipeline=$false)]
    [System.String]
    $fileShareName
)

$fileShareLocalPath = "\\$fileShareEndpoint\$fileShareName"

# Save the password so the drive will persist on reboot
Invoke-Expression -Command ("cmdkey /add:$fileShareEndpoint /user:AZURE\$fileShareStorageAccountName /pass:$fileShareStorageAccountKey")

$storageAccessKey = ConvertTo-SecureString -String $fileShareStorageAccountKey -AsPlainText -Force
$credentialStorage = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$fileShareStorageAccountName", $storageAccessKey
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $fileShareLocalPath -Credential $credentialStorage -Persist
