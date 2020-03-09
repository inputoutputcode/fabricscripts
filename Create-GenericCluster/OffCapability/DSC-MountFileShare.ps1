Script MapAzureShare
    {
        GetScript = 
        {

        }
        TestScript = 
        {
            Test-Path Z:
        }
        SetScript = 
        {
            Invoke-Expression -Command "cmdkey /add:somestorage.file.core.windows.net /user:somestorage /pass:somekey"
            Invoke-Expression -Command "net use W: \\somestorage.file.core.windows.net\someshare"
        }
        PsDscRunAsCredential = $credential
    }