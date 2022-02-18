## Set msbuild.exe as environment path
#[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\", [EnvironmentVariableTarget]::Machine)

## Set root path as parameter
$rootPath = "C:\Code\MKVIT171204\Backend\"

## VS Demo
## "C:\Code\MKVIT171120\packages\Microsoft.ServiceFabric.Actors.2.7.221\build\\FabActUtil.exe" /spp:"PackageRoot" /t:manifest /sp:"SendungsausgabeActor10" /in:"bin\x64\Release\\FunctionalComponents.SendungsausgabeActor10.Exe" /arp:"C:\Code\MKVIT171120\Backend\FunctionalComponents\SendungsausgabeActor10\bin\x64\Release\\" 

## Iterate through root path and build the packages
$rootDirectory = Get-ChildItem $rootPath -Recurse
$rootDirectory | Where { $_.extension -eq ".sfproj" } | Foreach {
    $projectFilePath = $_.DirectoryName + "\" + $_.Name
    msbuild $projectFilePath /t:Package /p:Configuration=Release /v:m
}
