Param (
      [string]$VHDLabel="Dev_Drive"             
      )
      # Find the volume by label
$volume = Get-Volume | Where-Object { $_.FileSystemLabel -eq "$VHDLabel" }

if (-not $volume) {
    Write-Host "Volume with label $VHDLabel not found." -ForegroundColor Red
    exit
}

# Find the physical disk for this volume
$partition = Get-Partition | Where-Object { $_.DriveLetter -eq $volume.DriveLetter }
$disk = Get-Disk | Where-Object { $_.Number -eq $partition.DiskNumber }

if ($disk) {
    Write-Host "Physical disk: $($disk.FriendlyName)"
    Write-Host "Disk number: $($disk.Number)"
    Write-Host "Device path: $((Get-VHD -DiskNumber $disk.Number).Path)"
} else {
    Write-Host "Failed to find the physical disk for this volume."
    exit
}
$vhdxPath=(Get-VHD -DiskNumber $disk.Number).Path

# Get the partition associated with the volume
#$partition = Get-Partition -DriveLetter $volume.DriveLetter

# Get the disk associated with the partition
#$disk = Get-Disk -Number $partition.DiskNumber

# Check if the disk is mounted as a VHD
if ($disk.BusType -ne "File Backed Virtual") {
    Write-Host "Error: The disk with label 'Dev_Drive' is not associated with a VHD."
    exit
}

# Get the current disk size
$currentSize = $disk.Size / 1GB
Write-Host "Current VHD size: $currentSize GB"

# Request a new size
$newSize = Read-Host "Enter the new desired size in GB (must be greater than the current: $currentSize GB)"

if ([int]$newSize -le [int]$currentSize) {
    Write-Host "Error: The new size must be greater than the current size."
    exit
}

$newSizeBytes = [long]$newSize * 1GB

# Resize the VHD (use Get-VHD for the exact path)
$vhdInfo = Get-VHD -Path $vhdxPath | Where-Object { $_.Number -eq $disk.Number }

if (-not $vhdInfo) {
    Write-Host "Error: Unable to find the associated VHD."
    exit
}

Write-Host "Resizing the VHD to $newSize GB..."
Resize-VHD -Path $vhdInfo.Path -SizeBytes $newSizeBytes

# Resize the partition
Write-Host "Resizing the partition on the disk..."
Resize-Partition -DiskNumber $disk.Number -PartitionNumber $partition.PartitionNumber -Size (Get-PartitionSupportedSize -DiskNumber $disk.Number -PartitionNumber $partition.PartitionNumber).SizeMax

Write-Host "The VHD and partition size have been successfully increased to $newSize GB."
