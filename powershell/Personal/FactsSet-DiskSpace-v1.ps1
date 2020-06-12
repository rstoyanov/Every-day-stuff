# Importing the list of managed servers to an array.
$servers = Get-Content -Path C:\serverList.txt

# Set a minimum disk space
$minDiskSpace = 20

# Creating an empty list to store server names that need space cleaning
$lowDiskSpace = @()

# Log Files Path
$logPath = ".\disk_usage.log"

# Cache directory
$cacheFolder = "C:\datacache\"

# Get the disk space values for each object in the list.

foreach ($s in $servers) {

     $disk = Get-WmiObject win32_logicaldisk -computername $s| Where-Object Name -eq "C:" |
        Select-Object PSComputerName, Name, 
            @{n="Size(GB)";e={[math]::Round($_.Size/1GB,2)}},
            @{n="FreeSpace(GB)";e={[math]::Round($_.FreeSpace/1GB,2)}}, 
            @{n="DiskSpace";e={[math]::Round(($_.FreeSpace / $_.Size *100),2)}}
            
# Checks if disk space is lower than the minimum value.
# If disk space is lower than the minimum value, it deletes older files in cache folder. 

    if ($disk.DiskSpace -le $minDiskSpace) {
        $lowDiskSpace += $disk.PSComputerName
        'Free Disk Space on ' + $disk.PSComputerName + ' is ' + $disk.DiskSpace + "%"| Out-File -FilePath $logPath -Append
        'Cleaning ' + $cacheFolder + ' on ' + $disk.PSComputerName | Out-File -FilePath $logPath -Append
        Invoke-Command -ComputerName $s -ScriptBlock { Get-ChildItem -Path $cacheFolder -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddHours(-12)} | Remove-Item }
    }
}