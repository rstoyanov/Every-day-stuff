$ErrorActionPreference = "Stop"

# Importing the list of managed servers to an array.
$servers = Get-Content -Path C:\serverList.txt

# Set a minimum disk space
$minDiskSpace = 22

# Creating an empty list to store server names that need space cleaning
$lowDiskSpace = @()

# Log Files Path
$logPath = ".\disk_usage.log"

# Cache directory
$cacheFolder = "C:\datacache\"

# Get the disk space values for each object in the list.

foreach ($s in $servers) {
    try {
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
            Get-ChildItem -Path $cacheFolder -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddHours(-12)} | Remove-Item
        }        
    }
    catch {
       "ERROR $error[0] " | Out-File -FilePath $logPath -Append
    }
}

 #Write-Host ("Server: {0} is not equal to server {1}" -f $s, $s)



#New-Item -Path C:\datacache\ -ItemType  Directory 

#CODE .\disk_usage.log

<#
s)O3%EY45KcLkt?)FUiDfL.dBRoZox9-
#>

<#

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

foreach ($s in $servers) {
    $disk = Get-WmiObject win32_logicaldisk -computername $s | Where-Object Name -eq "C:"
        $diskSize = [math]::round($disk.Size/1GB, 2)
        $diskFree = [math]::Round($disk.FreeSpace/1GB, 2)
        [PSCustomObject]@{
            "Drive" = $disk.Name
            "Disk Size" = $diskSize
            "Free Space %" = [math]::Round(($diskFree / $diskSize *100),2)
        }

}


foreach ($i in $values) {

    if ($i.HoursLeft -gt 30) {

        Write-Host "Delete values older than 24 hours on" $i.PSComputerName

    }
    elseif ($i.HoursLeft -lt 30) {

        Write-Host "Delete values older than 14 hours on" $i.PSComputerName

    }
    elseif ($i.HoursLeft -lt 20) {

    Write-Host "Delete values older than 5 hours on" $i.PSComputerName

    }


}


#$values | Where-Object {$_.HoursLeft -lt 30}

 

#>

#10gb/h

# size of disk / 10GB 

#gwmi win32_logicaldisk | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}
#@{Name='DiskUsage';Expression={[math]}::Round($_.freespace / $_.size)*100}
# Select-Object PSComputerName, Name,Freespace,Size,@{n='DiskUsage';e={[math]::Round($_.freespace / $_.size)*100,2}},@{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}
<#
winrm set winrm/config/client '@{TrustedHosts="46.10.210.164"}'

$CimCredential = Get-Credential -Credential "administrator"
$CimSessionOptions = New-CimSessionOption -SkipCNCheck
$CimSession = New-CimSession -ComputerName "ec2-52-14-219-189.us-east-2.compute.amazonaws.com" -Credential $CimCredential -SessionOption $CimSessionOptions
Get-CimInstance Win32_Service -CimSession $CimSession -Filter 'name = "WinRM"'

s)O3%EY45KcLkt?)FUiDfL.dBRoZox9-

help *remote*
help about_Remote_Troubleshooting

Invoke-Command -ComputerName "52.14.219.189" {Get-PSDrive C} -Credential $CimCredential

$getDrive = Get-PSDrive C | Select-Object Used,Free

$PSSession = New-PSSession -ComputerName "52.14.219.189" -Credential $CimCredential

Invoke-Command -ComputerName "52.14.219.189" -ScriptBlock { Get-ChildItem C:\ }


Set-Item wsman:\localhost\client\trustedhosts 52.14.219.189

#>

#Invoke-Command -ComputerName "52.14.219.189" {Get-PSDrive C} -Credential administrator