param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $serviceAccountUsername,

    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $serviceAccountPassword,

    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
    [System.String]
    $fileShareStorageAccountName,

    [Parameter(Mandatory=$True, Position=3, ValueFromPipeline=$false)]
    [System.String]
    $fileShareStorageAccountKey,

    [Parameter(Mandatory=$True, Position=4, ValueFromPipeline=$false)]
    [System.String]
    $fileShareEndpoint,

    [Parameter(Mandatory=$True, Position=5, ValueFromPipeline=$false)]
    [System.String]
    $fileShareName
)

$password = ConvertTo-SecureString -String $serviceAccountPassword -AsPlainText -Force
$credentialUser = New-Object System.Management.Automation.PSCredential -ArgumentList $serviceAccountUsername, $password
Start-Process -FilePath PowerShell.exe -ArgumentList ".\Mount-FileShare.ps1 $fileShareStorageAccountName $fileShareStorageAccountKey $fileShareEndpoint $fileShareName" -Credential $credentialUser -LoadUserProfile 