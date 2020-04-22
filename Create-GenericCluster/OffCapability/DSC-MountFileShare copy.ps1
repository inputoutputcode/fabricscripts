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

    Script CopyFilesFromAzureFileshare
    {
        SetScript =
        {
             New-PSDrive -Name $using:localMountDrive -PSProvider FileSystem -Root $using:fileshareSrcPath -Credential $using:fileshareCredential -Persist
        }
        TestScript = 
        {
            Test-Path "$using:localSrcPath\$using:fileshareInstallArchive" -PathType Leaf
        }
        GetScript = { @{ Result = '' } }
    }
   