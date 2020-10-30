$DvdDrv = Get-WmiObject -Class Win32_Volume -Filter "DriveType=5"
if ($DvdDrv -ne $null)
{
    $DvdDrv | Set-WmiInstance -Arguments @{DriveLetter="Z:"}
}

$disks = Get-Disk  | sort number
 
$letters = 80..85 | ForEach-Object { [char]$_ }
$count = 0
$label = "datadisk"
 
for($index = 2; $index -lt $disks.Count; $index++) {
    $driveLetter = $letters[$count].ToString()
    if ($disks[$index].partitionstyle -eq 'raw') {
        $disks[$index] | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter $driveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "$label.$count" -Confirm:$false -Force
    } else {
        $disks[$index] | Get-Partition | Set-Partition -NewDriveLetter $driveLetter
    }
    $count++
}
