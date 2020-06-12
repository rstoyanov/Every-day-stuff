$sourceFolder = "C:\Install\PS\"
$destinationFolder = "C:\TickSystems\"
$backupFolder = "C:\TS_Backup\"
$date = [DateTime]::Now.ToString("yyyyMMdd")
$scriptFolder = (Get-Item -Path ".\" -Verbose).FullName

<# 
.Synopsis 
   Write-Log writes a message to a specified log file with the current time stamp. 
.DESCRIPTION 
   The Write-Log function is designed to add logging capability to other scripts. 
   In addition to writing output and/or verbose you can write to a log file for 
   later debugging. 
.NOTES 
   Created by: Jason Wasser @wasserja 
   Modified: 11/24/2015 09:30:19 AM   
 
   Changelog: 
    * Code simplification and clarification - thanks to @juneb_get_help 
    * Added documentation. 
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
    * Revised the Force switch to work as it should - thanks to @JeffHicks 
 
   To Do: 
    * Add error handling if trying to create a log file in a inaccessible location. 
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
      duplicates. 
.PARAMETER Message 
   Message is the content that you wish to add to the log file.  
.PARAMETER Path 
   The path to the log file to which you would like to write. By default the function will  
   create the path and file if it does not exist.  
.PARAMETER Level 
   Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 
.PARAMETER NoClobber 
   Use NoClobber if you do not wish to overwrite an existing file. 
.EXAMPLE 
   Write-Log -Message 'Log message'  
   Writes the message to c:\Logs\PowerShellLog.log. 
.EXAMPLE 
   Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
   Writes the content to the specified log file and creates the path and file specified.  
.EXAMPLE 
   Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
   Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
.LINK 
   https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 
#> 
function Write-Log 
{ 
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
        [string]$Path="$scriptFolder\Logs\DeployService_$date.log",
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
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

Write-Log "Starting the script"

function New-Backup { 
    param 
    ( 
        [string] $Source = $(throw 'Source is required'), 
        [string] $Destination = $(throw 'Destination is required') 
    ) 
    
    if (Test-Path $Source) 
    { 
        if (-not (Test-Path $Destination)) 
        { 
            mkdir $Destination 
        } 
        
        $date = [DateTime]::Now.ToString("yyyyMMdd_HHmmss") 
        $backupLocation = "$Destination\Backup_$date"

        Copy-Item -Path $Source -Destination $backupLocation -Recurse 
    } 
}

function Copy-ConfigFiles ($SourceFolder, $DestinationFolder) {
 
    Copy-Item $SourceFolder\*.config -Destination $DestinationFolder 
}


function Get-ServiceName ($VersionedServiceName) {
    $tokens = $VersionedServiceName.Split("_")
    $tokens[0]
}

function Get-ServiceVersion ($VersionedServiceName) {
    $tokens = $VersionedServiceName.Split("_")
    $tokens[1]
}

function Get-ServicesToBeInstalled ($sourceFolder) {
    Get-Childitem $sourceFolder -recurse | where {$_.extension -eq ".zip"} | % {$_.BaseName}
}

function Archive-Backup {
    param
    (
        [string] $AcrhiveFileName,
        [string] $FolderToBeZipped
    )
    
    7z a -tzip $AcrhiveFileName $FolderToBeZipped
}

foreach ($ServiceToBeInstalled in Get-ServicesToBeInstalled $sourceFolder) {
        Write-Log "Processing: $ServiceToBeInstalled"
        $serviceName = Get-ServiceName $ServiceToBeInstalled
        $serviceNewVersion = Get-ServiceVersion $ServiceToBeInstalled
        $CurrentServicePath = Get-WmiObject win32_Service | ?{$_.Name -like "*$serviceName*"} | select PathName
        $CurrentServiceNameAndVersion = $CurrentServicePath.PathName.Split("\") -like "*_*"
        $CurrentServiceVersion = Get-ServiceVersion $CurrentServiceNameAndVersion
        $CurrentServiceWorkingFolder = (Split-Path $CurrentServicePath) -replace "@{PathName=", ""
        $NewServiceWorkingFolder = $CurrentServiceWorkingFolder -replace $CurrentServiceVersion, $serviceNewVersion
           
            try{
                if (($serviceName + "_" + $serviceNewVersion) -eq $CurrentServiceNameAndVersion) {
                        throw "$serviceName version $serviceNewVersion has already been installed" 
                }
            } 
            catch {
                Write-Log -Level Error $_.Exception.Message
                return $_.Exception.Message
            }

            if (Get-Service -Name "TS_$serviceName" -ErrorAction Stop -ErrorVariable ServiceError)  {
            }
            else {
                Write-Log -Level Error $ServiceError
            }

        Write-Log "Backing up: $CurrentServiceWorkingFolder to $backupFolder$CurrentServiceNameAndVersion"
        New-Backup -Source $CurrentServiceWorkingFolder -Destination "$backupFolder$CurrentServiceNameAndVersion"
        
        foreach ($FolderToBeArchived in (Get-ChildItem "$backupFolder$CurrentServiceNameAndVersion").Name ) {
                Set-Location "$backupFolder$CurrentServiceNameAndVersion"
                Archive-Backup "$FolderToBeArchived.zip" .\$FolderToBeArchived
                Remove-Item $FolderToBeArchived -Recurse
        }

        Write-Log "Extracting: $sourceFolder$ServiceToBeInstalled.zip to $destinationFolder$ServiceToBeInstalled"
        7z e -y "$sourceFolder$ServiceToBeInstalled.zip" -o"$destinationFolder$ServiceToBeInstalled" 
        $WindowsServiceName = "TS_" + $serviceName
        Write-Log "Copying config files from $CurrentServiceWorkingFolder to $NewServiceWorkingFolder"
        Copy-ConfigFiles "$CurrentServiceWorkingFolder" "$NewServiceWorkingFolder" -ErrorAction SilentlyContinue -ErrorVariable CopyFilesError
            
            if ($CopyFilesError) {
                Write-Log -Level Error "$CopyFilesError"
            }
            else {
                Write-Log "Successfully copied the configuration files"
            }

        Write-Log "Setting $WindowsServiceName -StartupType to Disabled"
        Set-Service -Name $WindowsServiceName -StartupType Disabled
        Write-Log "Stopping Service $WindowsServiceName"
        Get-Service -Name $WindowsServiceName | Stop-Service
        Write-Log "Setting $WindowsServiceName Path to $NewServiceWorkingFolder\$serviceName.Host.exe" 
        sc.exe config "$WindowsServiceName" binpath= "$NewServiceWorkingFolder\$serviceName.Host.exe"
} 

$WindowsServiceStoppedList = Get-Service -Name "TS_*" | Where-Object {$_.Status -eq "Stopped"}

Write-Log "Getting dependent services"

foreach ($WindowsServiceStopped in $WindowsServiceStoppedList) {
     foreach ($dependentService in (Get-Service -Name $WindowsServiceStopped.Name).ServicesDependedOn ) {
         if
            ($dependentService.Status -eq "Stopped") {
            Set-Service -Name $dependentService.name -StartupType Automatic
            Get-Service -Name $dependentService.name | Start-Service -ErrorAction Stop -ErrorVariable ServiceStartError
         }
         else {
         Write-Log $ServiceStartError
         }
     }
}

Write-Log "Script finished"   

    
