Param (
      [string]$VHDLabel="Dev_Drive"             
      )
      # Найти том с меткой 
$volume = Get-Volume | Where-Object { $_.FileSystemLabel -eq "$VHDLabel" }

if (-not $volume) {
    Write-Host "Диск с меткой $VHDLabel не найден." -ForegroundColor Red
    exit
}

# Найти физический диск для этого тома
$partition = Get-Partition | Where-Object { $_.DriveLetter -eq $volume.DriveLetter }
$disk = Get-Disk | Where-Object { $_.Number -eq $partition.DiskNumber }

if ($disk) {
    Write-Host "Физический диск: $($disk.FriendlyName)"
    Write-Host "Номер диска: $($disk.Number)"
    Write-Host "Путь устройства: $((Get-VHD -DiskNumber $disk.Number).Path)"
} else {
    Write-Host "Не удалось найти физический диск для данного тома."
    exit
}
$vhdxPath=(Get-VHD -DiskNumber $disk.Number).Path