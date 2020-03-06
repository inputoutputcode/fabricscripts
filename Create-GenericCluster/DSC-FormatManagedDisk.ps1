##############################################################################
##
## manageddisksetup.ps1
##
## Copyright (c) Microsoft Corporation.  All rights reserved.
##
##############################################################################

<#
.SYNOPSIS

Mount and initializes attached managed disk, and setupup junction point for diagnostics.

.EXAMPLE
.\manageddisksetup.ps1

Mount and initializes attached managed disk, and setup junction point for diagnostics.

#>
[CmdletBinding()]
param (
    # default service fabric data drive letter
    [Parameter(Mandatory=$false)]
    [ValidateSet("F", "G","H", "G","H","I","J","K","L","M","O","P","Q","R","S","T","U","V","W","X","Y")]
    [string]
    $FabricDataDriveLetter="Y",

    # ServiceFabric data disk friendly name
    [Parameter(Mandatory=$false)]
    [string]
    $FabricDataDiskFriendlyName="FabricDisk",

    # File system label for ServiceFabric data volume
    [Parameter(Mandatory=$false)]
    [string]
    $FabricDataVolumeFileSystemLabel="FabricDisk",

    # (Parameter help description)
    [Parameter(Mandatory=$false)]
    [int]    
    $SFDataLunId=0,

    # Parameter help description
    [Parameter(Mandatory=$false)]
    [bool]
    $UseRAID0=$false
)


$ErrorActionPreference = "Stop"

try
{
    Write-Host "Initialize managed disk started"
    
    # step1: verify sf drive letter is already mounted. if true exit with success.
    $volume = Get-Volume -DriveLetter $FabricDataDriveLetter -ErrorAction SilentlyContinue

    if(-not($null -eq $volume))
    {
        Write-Host "Drive $FabricDataDriveLetter is already setup. exiting with success."
        return 0;
    }
    
    Write-Verbose "$FabricDataDriveLetter doesnot exists. proceeding to query disk by its FriendlyName: $FabricDataDiskFriendlyName"

    $sfDataDisk = Get-Disk -FriendlyName $FabricDataDiskFriendlyName

    if($null -eq $sfDataDisk) {
        Write-Host "Disk with FriendlyName: $FabricDataDiskFriendlyName not found. Proceed with raw disk formatting and volume creation."

        #step2: retrive all disks that can be mounted. 
        $physicalDisks = (Get-PhysicalDisk -CanPool $true -ErrorAction SilentlyContinue) 
    
        Write-Verbose "Get-PhysicalDisk -CanPool $true = $physicalDisks "

        #step3_1: if no raw disk found for mounting fail. 
        if ($null -eq $physicalDisks) {
            Write-Error "no physical disk found for $FabricDataDriveLetter drive." 
            return -1;
        }

        Write-Verbose "(Get-PhysicalDisk -CanPool $true ).Count= $($physicalDisks.Count)"

        #step3_2: check if count is 0, if true no disk available for sfdata, fail 
        if ($physicalDisks.Count -eq 0) {        
            if ($null -eq $volume) {
                Write-Error "no physical disk found for $FabricDataDriveLetter drive." 
            }
            return -1;
        }

        #step4: if use raid0 setup set to false then pick 1st disk for SF, TODO: specify disk name from top /lun id for picking sfdata and sflog disk
        if($UseRAID0) {
            if ($null -eq $physicalDisks.Count){
                Write-Verbose "physicalDisks.Count=$($physicalDisks.Count) is null"
                $disks=@($physicalDisks)
            }else {
                Write-Verbose "assigning disks=$($physicalDisks) is null"
                $disks=$physicalDisks
            }
        }
        else {
            if ($null -eq $physicalDisks.Count) {  
                Write-Verbose "assigning disks=$($physicalDisks) is null"
                $disks=@($physicalDisks)
            }
            else {
                $disks=$null
                foreach ($disk in $physicalDisks) {  
                    if (-not($null -eq $disk) -and -not($null -eq ((Get-Disk -Number $disk.DeviceId).Location))) {                    
                        Write-Verbose "((Get-Disk -Number $(($disk).DeviceId).Location)).Contains('LUN $SFDataLunId') = $(((Get-Disk -Number ($disk).DeviceId).Location).Contains("LUN $SFDataLunId"))"
                        if (((Get-Disk -Number ($disk).DeviceId).Location).Contains("LUN $SFDataLunId")) {
                            Write-Verbose "Assigning deviceId:$(($disk).DeviceId) to disks variable"
                            $disks = @($disk);
                            break;
                        }
                    }
                    else {
                        Write-Verbose "$($disk.DeviceId) is null or already mounted"
                    }
                }
            }
        }

        Write-Verbose "$disks found"

        if (($null -eq $disks) -or ($disks.Count -le 0)) {        
            Write-Error "no physical disk found for $FabricDataDriveLetter drive." 
            return -1;
        }

        #step5: mount disk  
        New-StoragePool -FriendlyName "ServiceFabricData" `
            -StorageSubsystemFriendlyName "Windows Storage*" `
            -PhysicalDisks $disks -ResiliencySettingNameDefault Mirror `
            -ProvisioningTypeDefault Thin | New-VirtualDisk -FriendlyName $FabricDataDiskFriendlyName `
            -Interleave 65536 -NumberOfColumns $disks.Count `
            -ProvisioningType Fixed -ResiliencySettingName "Simple" `
            -UseMaximumSize | Initialize-Disk -PassThru | New-Partition -UseMaximumSize -DriveLetter $FabricDataDriveLetter | Format-Volume

        #step6: validate mouting succeeded.
        $volume = Get-Volume -DriveLetter $FabricDataDriveLetter
        if($null -eq $volume) {
            Write-Error "Mounting failed. no $FabricDataDriveLetter found"
            return -1;
        }

        #step7: set file-system label
        Set-Volume -NewFileSystemLabel $FabricDataVolumeFileSystemLabel -DriveLetter $FabricDataDriveLetter

        #step8: validate file-system label succeeded.
        $volume = Get-Volume -FileSystemLabel $FabricDataVolumeFileSystemLabel
        if($null -eq $volume) {
            Write-Error "Set-Volume failed. no $FabricDataVolumeFileSystemLabel found"
            return -1;
        }
    }
    else {
        $volume = Get-Volume -FileSystemLabel $FabricDataVolumeFileSystemLabel -ErrorAction SilentlyContinue
        if($null -eq $volume) {
            Write-Error "Volume with label: $FabricDataVolumeFileSystemLabel is not found"
            return -1;
        }

        if ($volume.DriveLetter -ne $FabricDataDriveLetter) {
            # Change the current DriveLetter of the volume to the desired DriveLetter
            Write-Host "Changing DriveLetter from $($volume.DriveLetter) to $FabricDataDriveLetter"
            Get-Partition -DriveLetter $volume.DriveLetter | Set-Partition -NewDriveLetter $FabricDataDriveLetter
            $volume = Get-Volume -DriveLetter $FabricDataDriveLetter -ErrorAction SilentlyContinue
            if($null -eq $volume) {
                Write-Error "Unable to set DriveLetter:$FabricDataDriveLetter for volume: $FabricDataVolumeFileSystemLabel"
                return -1;
            }
        }
    }
   
}
catch
{
    Write-Host "Initialize managed disk failed"
    Write-Error -Message $_.Exception.Message
    throw $_.Exception
}