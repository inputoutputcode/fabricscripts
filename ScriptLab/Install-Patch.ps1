$windowsVersion = [System.Environment]::OSVersion.Version

Write-Host("Windows version is $($windowsVersion)")
$installer = "";
if ($windowsVersion.Major -eq "6")
{
    Write-Host("Windows version is 2012 R2")    
    $installer = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/07/windows8.1-kb4345424-x64_5e9e057b130d4cadea5f719d795fc8d8f4cf4310.msu"
}
elseif ($windowsVersion.Major -eq "10")
{    
    if ($windowsVersion.Build -eq "14393")
    {
        # RS1
        Write-Host("Windows version is 2016 14393")        
        $installer = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2018/07/windows10.0-kb4345418-x64_a636a1048a2601d9218463107bc5fde558a1055e.msu"
    }       
    elseif ($windowsVersion.Build -eq "16299")
    {
        # RS3
        Write-Host("Windows version is 2016 16299")        
        $installer = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/07/windows10.0-kb4345420-x64_94968c844473fcbbb4329808d5d3c9b06dcd3dbc.msu"
    }    
    elseif ($windowsVersion.Build -eq "17134")
    {
        # RS4
        Write-Host("Windows version is 2016 17134")       
        $installer = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/07/windows10.0-kb4345421-x64_c5a035dc1ec030a5be0626c8b019b9c4f6e8a1a6.msu"
    }    
    else
    {
        Write-Error "Could not determine Windows Version"
        exit(1)
    }
    
}
else
{
    Write-Error "Could not determine Windows Version"
    exit(2)
}

$dest = "$PWD\$(Split-Path -Leaf $installer)"
Write-Host "Downloading...the destination will be $dest"
wget $installer -out $dest

Write-Host "Installing..."
wusa $dest /quiet /warnrestart:30


