# Enabling PSRemoting on the remote servers is neccessery before using the script.

#Importing the list of managed servers to an array.
$servers = Get-Content -Path C:\serverList.txt

#Set a minimum disk space
$minDiskSpace = 20

# Creating an empty list to store server names that need space cleaning
$lowDiskSpace = @()

# Get the disk space values for each object in the list.
$values = Get-WmiObject win32_logicaldisk -computername $servers | Where-Object Name -eq "C:" |
    Select-Object PSComputerName, Name, 
        @{n="Size(GB)";e={[math]::Round($_.Size/1GB,2)}},
        @{n="FreeSpace(GB)";e={[math]::Round($_.FreeSpace/1GB,2)}}, 
        @{n="DiskUsage";e={[math]::Round(($_.FreeSpace / $_.Size *100),2)}}

#Check if there are disks with low disk space
foreach ($i in $values ) {
        if ($i.DiskUsage -le $minDiskSpace) {
            $lowDiskSpace += $i.PSComputerName
            Write-Host 'Disk Usage on' $i.PSComputerName 'is' $i.DiskUsage
        }
}  

