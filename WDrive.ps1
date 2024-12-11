Param (
    [char]$drvletter='W'
    [string]$Mode = "Create", #Create | Copy
    [string]$CopySource = "replace with \\server\share\Image.vhd" # Prefab image                  

# Проверка наличия модуля Hyper-V
$featureName = "Microsoft-Hyper-V-All"
$feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName

if ($feature.State -ne "Enabled") {
    Write-Host "Модуль Hyper-V не установлен. Устанавливаем..."
    Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart

    Write-Host "Hyper-V установлен. Перезагрузка системы для завершения установки..."
   # shutdown.exe /r /t 0
  #  exit
}
function Get-ImagePath {
    # Проверяем количество дисков, кроме диска C: и сетевых
    $disks = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne "C" -and -not ($_.DisplayRoot -like "\\*") }

    if ($disks.Count -gt 0) {
        foreach ($disk in $disks) {
            # Проверяем свободное место на каждом диске
            if ($disk.Free -gt 10GB) {$vhdxPath = Join-Path $disk.Root "Dev_DriveDLP.vhdx"
            return $vhdxPath}
            }
            else {$vhdxPath = Join-Path $disk.Root "c:\DevDrive\Dev_DriveDLP.vhdx"}}
            
            return $vhdxPath
}

# Функция для проверки и монтирования VHDX
function Create-And-Mount-VHD {

                # Путь для хранения VHDX файла
                
                
                # Проверяем, существует ли уже VHDX
                if (-Not (Test-Path $vhdxPath)) {
                    # Создаем VHDX диск
                    New-VHD -Path $vhdxPath -SizeBytes 10GB -Dynamic
                    
                    # Монтируем VHDX
                    Mount-VHD -Path $vhdxPath
                    
                    # Проверяем, доступна ли буква W:
                    $drvletter='W'



                    $drvlist=(Get-PSDrive -PSProvider filesystem).Name
                     If ($drvlist -notcontains $drvletter) {
                        # Инициализируем VHD и форматируем его
                        # Ищем первый диск с PartitionStyle "RAW"
$rawDisk = Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" } | Select-Object -First 1

if ($null -eq $rawDisk) {
    Write-Host "Не найден диск с PartitionStyle 'RAW'. Убедитесь, что VHDX корректно создан и подключен."
    return
}

# Инициализируем диск
Initialize-Disk -Number $rawDisk.Number -PartitionStyle MBR

# Создаем новый раздел и присваиваем ему букву
$partition = New-Partition -DiskNumber $rawDisk.Number -UseMaximumSize -DriveLetter $drvletter

# Форматируем раздел
Format-Volume -DriveLetter $partition.DriveLetter -FileSystem NTFS -NewFileSystemLabel "Dev_Drive"

Write-Host "Диск успешно создан и форматирован."

                        
                        
                        Write-Host "Диск W: успешно создан и настроен на постоянное монтирование."
                    } else {
                        Write-Host "Буква W: уже занята."
                    }
                } else {
                    Write-Host "Файл $vhdxPath уже существует."
                }
                break
            } else {
                Write-Host "На диске $($disk.Name): недостаточно свободного места."
            }
        }
    } else {
        Write-Host "Жестких дисков кроме C: не найдено."
    }
}
function Create-Task
{
# Настраиваем постоянное монтирование
                        $taskName = "Mount Dev_Drive"
                        $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
                        Register-ScheduledTask -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command Mount-VHD -Path $vhdxPath") `
                                               -Trigger (New-ScheduledTaskTrigger -AtStartup) `
                                               -TaskName $taskName `
                                               -Settings $taskSettings `
                                               -Description "Automatically mount Dev_Drive on startup" `
                                               -User "SYSTEM" `
                                               -RunLevel Highest
}
# Выполнение основной функции
Create-And-Mount-VHD
Create-Task
