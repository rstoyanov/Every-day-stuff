
<#   
.SYNOPSIS   
This script was created according to FACTSET pre-interview task specifications. It checks the available free space on remote servers and if it is less
    
.DESCRIPTION 
The script checks the available free space on remote servers and if it is less than specified, deletes older files from specified cache folder.
	
.PARAMETER ServerName
This parameter can be used to specify one or multiple servers in a string.

.PARAMETER ServerListPath
A text file can be provided with list of servers. Example: "C:\serverlist.txt"

.PARAMETER FolderPath
The path to the data cache folder. Example: "C:\datacache"

.PARAMETER PercentFreeSpace
Desired free space in %

.PARAMETER LogPath
Path to the log file wich will be created. Example: "C:\scriptlog.log"

.PARAMETER FileAgeHours
This parameter indicates the age of the files in hours, which will be kept after deletion. If value is set to 5, all files older than 5 hours will be removed. 

.PARAMETER CreationTime
This switch tells the script whitch time to be considered for the calculation. In this case it gets $_.CreationTime

.PARAMETER ModifyTime
This switch tells the script whitch time to be considered for the calculation. In this case it gets $_.LastWriteTime

.NOTES   
Name: Remove-CacheFiles.ps1
Author: Radostin Stoyanov
Version: 1.0.0
DateCreated: 2019-08-11
DateUpdated: 2019-08-11

.EXAMPLE   

.\Remove-CacheFiles.ps1 -ServerListPath "C:\serverlist.txt" -FolderPath "C:\datacache\" -PercentFreeSpace 20 -LogPath "C:\disk.log" -FileAgeHours 5 -ModifyTime

Description:

Gets the list of servers from file, checks if it is less than 20% free space, and if yes, it deletes files older than 5 hours using LastWriteTime

#>

param (
    [Parameter(ValueFromPipelineByPropertyName=$true)] 
    [string]$ServerName,
    [Parameter(ValueFromPipelineByPropertyName=$true)] 
    [array]$ServerListPath,
    [string]$FolderPath,
    [decimal]$PercentFreeSpace,
    [string]$LogPath ,
    [decimal]$FileAgeHours,
    [switch]$CreationTime,
    [switch]$ModifyTime
)

function Write-Log { 

    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path=$LogPath,
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info" 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

$ErrorActionPreference = "Stop"

if (-not ($ServerName -or $ServerListPath)) {Write-Log "Please specify either -ServerName or -ServerListPath";exit}
if (-not $FolderPath) {Write-Log "Please specify -FolderPath parameter, which indicates the directory where the files will be removed from";exit}
if (-not $PercentFreeSpace) {Write-Log "Please specify -PercentFreeSpace parameter, which indicates the minimum disk space required";exit}
if (-not $LogPath) {Write-Log "Please specify -LogPath, where log file will be created. Folder and File name.";exit}
if (-not $FileAgeHours) {Write-Log "Please specify -FileAgeHours, wich indicates how old would be the files to be removed";exit}
if (-not ($CreationTime -or $ModifyTime)) {Write-Log "Please specify either -CreationTime or -ModifyTime, wich indicates what time on the file to be used as last time";exit}

if ($ServerListPath) {[array]$ServerName = Get-Content $ServerListPath}

foreach ($s in $ServerName) {
    try {
        Write-Log "Getting disk usage info for $s..."
        $disk = Get-WmiObject win32_logicaldisk -computername $s| Where-Object Name -eq "C:" |
        Select-Object PSComputerName, Name, 
            @{n="Size(GB)";e={[math]::Round($_.Size/1GB,2)}},
            @{n="FreeSpace(GB)";e={[math]::Round($_.FreeSpace/1GB,2)}}, 
            @{n="DiskSpace";e={[math]::Round(($_.FreeSpace / $_.Size *100),2)}} 
        $psComputerName = $disk.PSComputerName
        $diskSpace = $disk.DiskSpace

        # Checks if disk space is lower than the minimum value.
        if ($disk.DiskSpace -le $PercentFreeSpace) {
            Write-Log  "Free Disk Space on $psComputerName is $diskSpace%"
            Write-Log "Cleaning $FolderPath on $psComputerName"

            # Deletes the files in cache directory
            if ($CreationTime) {
                Write-Log "Deleting files based on CreationTime"
                Invoke-Command -ComputerName $s -ScriptBlock {Get-ChildItem -Path $FolderPath -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddHours(-$FileAgeHours)} | Remove-Item}
            }
            elseif ($ModifyTime) {
                Write-Log "Deleting files based on LastWriteTime"
                Invoke-Command -ComputerName $s -ScriptBlock {Get-ChildItem -Path $FolderPath -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddHours(-$FileAgeHours)} | Remove-Item}
            }
        }        
    }
    catch {
        [string]$err = $_.Exception.Message
        Write-Log $err -Level Warn
        
    }
}
