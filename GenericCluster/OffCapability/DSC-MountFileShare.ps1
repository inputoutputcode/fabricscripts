Script MapAzureFileShare
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $credential
    )
    GetScript = 
    {

    }
    TestScript = 
    {
        Test-Path Z:
    }
    SetScript = 
    {
        $fileShareLocalPath = "\\$credential.UserName\sfdatashare"
        $credentialStorage = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$credential.UserName", $credential.Password
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root $fileShareLocalPath -Credential $credentialStorage -Persist
    }
}