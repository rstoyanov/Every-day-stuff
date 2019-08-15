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
        [string]$Path=".\get-diskusage.log",
         
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

# Importing the list of managed servers to an array.
$servers = Get-Content -Path C:\serverList.txt

# Set a minimum disk space
$minDiskSpace = 30

# Creating an empty list to store server names that need space cleaning
$lowDiskSpace = @()

# Log Files Path
$logPath = ".\get-diskusage.log"

# Cache directory
$cacheFolder = "C:\datacache\"

# Get the disk space values for each object in the list.

foreach ($s in $servers) {
    try {
        Write-Log "Getting disk usage info for $s..."
        $disk = Get-WmiObject win32_logicaldisk -computername $s| Where-Object Name -eq "C:" |
        Select-Object PSComputerName, Name, 
            @{n="Size(GB)";e={[math]::Round($_.Size/1GB,2)}},
            @{n="FreeSpace(GB)";e={[math]::Round($_.FreeSpace/1GB,2)}}, 
            @{n="DiskSpace";e={[math]::Round(($_.FreeSpace / $_.Size *100),2)}} 

        # Checks if disk space is lower than the minimum value.
        # If disk space is lower than the minimum value, it deletes older files in cache folder. 
        Write-Log "Start cleaning cache folder on $s"
        if ($disk.DiskSpace -le $minDiskSpace) {
            $lowDiskSpace += $disk.PSComputerName
            'Free Disk Space on ' + $disk.PSComputerName + ' is ' + $disk.DiskSpace + "%"| Out-File -FilePath $logPath -Append
            'Cleaning ' + $cacheFolder + ' on ' + $disk.PSComputerName | Out-File -FilePath $logPath -Append
            #Invoke-Command -ComputerName $s -ScriptBlock {Get-ChildItem -Path $cacheFolder -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddHours(-12)} | Remove-Item}
        }        
    }
    catch {
        [string]$err = $_.Exception.Message
        Write-Log $err -Level Warn
        
    }
}
