$sourceFolder = "C:\Install\PS\"
$destinationFolder = "C:\TickSystems\"
$backupFolder = "C:\TS_Backup\"
$fileVersionPath = "C:\Install\PS\"
$fileName = "fileVersion.txt"
$oldFileName = "oldFileVersion.txt"

Clear-Host
Write-Host ""
Write-Host ""
Write-Output "!! Starting the deployment process!!"
Start-Sleep 2

#Gatering the list of services to deploy

Write-Host ""
Write-Output "-- Gathering the service names"
Start-Sleep 2

$serviceList = get-childitem $sourceFolder -recurse | where {$_.extension -eq ".zip"} | % {$_.BaseName}

if (Test-Path -Path $fileVersionPath$oldFileName) {
    Write-Output "- File $oldFileName already exists. Deleting the file."
    Remove-Item -Path $fileVersionPath$oldFileName
}
else {
    Write-Output "- File $oldFileName doesn't exist, moving on."
}


if (Test-Path -Path $fileVersionPath$fileName ) {
    Write-Output "- File $fileName already exists. Renaming it to $oldFileName"
    Rename-Item $fileVersionPath$fileName -NewName $oldFileName
}

else {
    Write-Output "- File $fileName doesn't exist, moving on."
}

$serviceList | Out-File $fileVersionPath$fileName

# Stopping the services and setting StartupType Disabled.

foreach ($service in $serviceList) {

    $tokens = $service.Split("_")
    $serviceName = "TS_" + $tokens[0]
    $serviceVersion = $tokens[1]
    Write-Host ""
    Write-Output "-- Stopping service $serviceName"
    Get-Service -Name $serviceName | Stop-Service
    Start-Sleep 5
    Write-Host ""
    Write-Output "-- Setting StartupType of service $serviceName to Disabled"
    Set-Service -Name $serviceName -StartupType Disabled
}

# Backing up the service folders

$folderList = get-childitem $destinationFolder

foreach ($folder in $folderList) {
    Write-Host ""
    Write-Output "-- Backing up $folder folder"
    $tokens = $folder.name.Split("_")
    New-Backup -Source "$destinationFolder$folder" -Destination "$backupFolder$folder"
    Start-Sleep 2
}

cd $sourceFolder

foreach ($service in $serviceList) {
    7z e -y "$service.zip" -o"$destinationFolder$service"
}