try
{
	Write-Host "Initialize attached disk started."
	
	$disks = Get-Disk | Where PartitionStyle -eq 'RAW' 

	$disks | %{ Write-Host $_ } 
	  
	$disks | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter Y  | Format-Volume -FileSystem NTFS -NewFileSystemLabel "datadisk" -Confirm:$false
	Write-Host "Initialize managed disk completed."
	
}
catch
{
	Write-Host "Initialize managed disk failed."
	Write-Error -Message $_.Exception.Message
    throw $_.Exception
}