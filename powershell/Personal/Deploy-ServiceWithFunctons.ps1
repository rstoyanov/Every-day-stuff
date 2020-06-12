$sourceFolder = "C:\Install\PS\"
$destinationFolder = "C:\TickSystems\"
$backupFolder = "C:\TS_Backup\"
$GlobalDate = [DateTime]::Now.ToString("yyyyMMdd")
$scriptFolder = (Get-Item -Path ".\" -Verbose).FullName

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
        [string]$Path=(Get-Location).path,
         
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

function Get-ServiceName  ($VersionedServiceName) {
    $tokens = $VersionedServiceName.Split("_")
    $tokens[0]
}

function Get-ServiceVersion ($VersionedServiceName) {
    $tokens = $VersionedServiceName.Split("_")
    $tokens[1]
}

function Get-ServicesToBeInstalled {
    param (

    )

    $ServicesToBeInstalledList = Get-Childitem $sourceFolder -recurse | where {($_.extension -eq ".zip") -and -not ($_.Name.StartsWith("Web"))} | % {$_.BaseName}

    $result = @()

    foreach ($serviceToBeInstalled in $ServicesToBeInstalledList) {

            $serviceName = Get-ServiceName $ServiceToBeInstalled
            $serviceNewVersion = Get-ServiceVersion $ServiceToBeInstalled
            
            if ((Get-WmiObject win32_Service | ?{$_.Name -like "*$serviceName*"}) -ne $null) {
                $CurrentServicePath = Get-WmiObject win32_Service | ?{$_.Name -like "*$serviceName*"} | select PathName
                [string]$CurrentServiceNameAndVersion = $CurrentServicePath.PathName.Split("\") -like "*_*"
                $CurrentServiceVersion = Get-ServiceVersion $CurrentServiceNameAndVersion
                $CurrentServiceWorkingFolder = (Split-Path $CurrentServicePath) -replace "@{PathName=", ""
                $NewServiceWorkingFolder = $CurrentServiceWorkingFolder -replace $CurrentServiceVersion, $serviceNewVersion
                $NewSeviceNameAndVersion = $serviceName + "_" + $serviceNewVersion
            }
            else {
                $CurrentServicePath = $null
                [string]$CurrentServiceNameAndVersion = $null
                $CurrentServiceVersion = $null
                $CurrentServiceWorkingFolder = $null
                $NewServiceWorkingFolder = $destinationFolder + $serviceName + "\" + $serviceName + "_" + $serviceNewVersion
                $NewSeviceNameAndVersion = $serviceName + "_" + $serviceNewVersion
            }


            $result += New-object psobject -property  @{ServiceName = $serviceName; 
                                                        Current_Sevice_Name_And_Version = $CurrentServiceNameAndVersion;
                                                        New_Version = $serviceNewVersion; 
                                                        Current_Version = $CurrentServiceVersion;
                                                        Current_Working_Folder = $CurrentServiceWorkingFolder;
                                                        New_Working_Folder = $NewServiceWorkingFolder;
                                                        New_Service_Name_And_Version = $NewSeviceNameAndVersion                                                    
                                                        }
        
    }
 
    return $result

}

function Check-DeploymentPrerequisites {

$ServicesToBeInstalled = Get-ServicesToBeInstalled

    foreach ($ServiceToBeInstalled in $ServicesToBeInstalled) {


        if ($ServiceToBeInstalled.New_Service_Name_And_Version -eq $ServiceToBeInstalled.Current_Sevice_Name_And_Version) {
                $NewService = $ServiceToBeInstalled.New_Service_Name_And_Version
                $message = "$NewService has already been installed"
                Write-Log -Level Error $message
                throw $message
        }
        else {
            $NewService = $ServiceToBeInstalled.New_Service_Name_And_Version
            Write-Log "The check of $NewService completed. All requirements are fullfiled"
        }

       <# $Service = (Get-Service -Name ("TS_" + $ServiceToBeInstalled.ServiceName))
        if (("TS_" + $ServiceToBeI nstalled.ServiceName) -ne $service.Name) {
            $serviceName = ("TS_" + $ServiceToBeInstalled.ServiceName)
            $servicePath = $ServiceToBeInstalled.New_Working_Folder
            Write-Log "Service $serviceName doesn't exists. Installing a new service"
            sc.exe create $serviceName binpath= $servicePath

        }#>

    }
}

function New-Backup { 
    param 
    ( 
    ) 
        
    $date = [DateTime]::Now.ToString("yyyyMMdd_HHmmss") 
    $ServicesToBeInstalled = Get-ServicesToBeInstalled
        
    foreach ($Service in $ServicesToBeInstalled) {
        $Source = ($Service.Current_Working_Folder) + "\"
        $Destination = $backupFolder + $Service.Current_Sevice_Name_And_Version
        $backupLocation = "$Destination\Backup_$date"
        $ServiceNameAndVersion = $Service.Current_Sevice_Name_And_Version
        $ServiceName = $Service.ServiceName

        Write-Log "Backing up $ServiceNameAndVersion"
       
       if($Service.Current_Working_Folder -ne $null) {
        Copy-Item -Path $Source -Destination $backupLocation -Recurse -ErrorAction SilentlyContinue -ErrorVariable backuperror
        }
        else{
        Write-Log "Service $ServiceName is not installed" 
        }
            if ($backuperror) {
                Write-Log -Level Error "$backuperror"
            }
            else {
                Write-Log "Backup completed successfully"
            }

    } 
} 

<#function Archive-Backup {
    param
    (
    )

    $ServicesToBeInstalled = Get-ServicesToBeInstalled 

    foreach ($Service in $ServicesToBeInstalled) {
            $ServiceName = $Service.ServiceName 
            Write-Host "Processing $ServiceName"
            
            if ($Service.Current_Working_Folder -ne $null) {
                $Location = $backupFolder + $Service.Current_Sevice_Name_And_Version
                $ServiceName = $Service.Current_Sevice_Name_And_Version
                $FolderToBeArchived = Get-ChildItem $Location -Recurse | ?{ $_.PSIsContainer }
                Write-Log "Setting location to: $Location"
                Set-Location $Location 
                Write-Log "Zipping: $Location _ $FolderToBeArchived"
                7z.exe a -tzip "$FolderToBeArchived.zip" .\ 
                Write-Log "Removing: $Location_$FolderToBeArchived"
                Remove-Item $FolderToBeArchived -Recurse
            }
            else {
            Write-Host "$ServiceName is not installed"
            }
    }
    
}#>

<#function Archive-TEST {
    param
    (
    )

    $ServicesToBeInstalled = Get-ServicesToBeInstalled 

    foreach ($Service in $ServicesToBeInstalled) {
            $ServiceName = $Service.ServiceName 
            $ServiceNameAndVersion = $Service.Current_Sevice_Name_And_Version
            Write-Host "Processing $ServiceName and $ServiceNameAndVersion"

            
            if ($Service.Current_Sevice_Name_And_Version -ne "Null") {
            Write-Host "$ServiceName is installed"
            }
            else {

            Write-Host "$ServiceName is not installed"

            }
    }
    
}#>

function Extract-GlobalAchive {
    param 
    (
    )
        $Source = $sourceFolder + "RM*.zip"
        $Destination = $sourceFolder
        $Result = Get-Childitem $sourceFolder -recurse | where {$_.Name -like "RM*"} | % {$_.Name}
        $message = 

        if ($Result -ne $null) {
        

            Write-Log "Extracting $sourceFolder + RM*.zip"
            7z e -y $Source -o"$Destination"
            Write-Log "Removing $sourceFolder + RM*.zip"
            Remove-Item "$sourceFolder$Result"

        }
        else {
            throw "RM* archive file is missing"
        }
}

function Extract-Service {
    param 
    (
    )

        $ServicesToBeInstalled = Get-ServicesToBeInstalled

        foreach ($Service in $ServicesToBeInstalled) {
            $Source = $sourceFolder + ($Service.New_Service_Name_And_Version) + ".zip"
            $Destination = $destinationFolder + ($Service.ServiceName) + "\"+ ($Service.New_Service_Name_And_Version) + "\"
            $FileName = ($Service.New_Service_Name_And_Version) + ".zip"
            Write-Log "Extracting $FileName to $Destination"
            7z e -y $Source -o"$Destination" 
         } 

            

}

function Copy-ConfigFiles {
    param
        (
        ) 

        $ServicesToBeInstalled = Get-ServicesToBeInstalled
        
        foreach ($Service in $ServicesToBeInstalled) {
            $Source = ($Service.Current_Working_Folder) + "\*.config"
            $Destination = ($Service.New_Working_Folder) + "\"
            $ServiceName = $Service.ServiceName

            if($Service.Current_Working_Folder -ne $null) {
                Write-Log "Copying config files from $Source to $Destination"
                Copy-Item $Source -Destination $Destination -ErrorAction SilentlyContinue -ErrorVariable copyconfigerror
                
                if ($copyconfigerror) {
                    Write-Log -Level Error "$copyconfigerror"
                }
                else {
                    Write-Log "Config files copied successfully"
                }
            }
            else{
            Write-Log "Service $ServiceName is not installed"
            }

        } 
}

function Stop-RMServices {

        $ServicesToBeInstalled = Get-ServicesToBeInstalled

        foreach ($Service in $ServicesToBeInstalled) {
            $WindowsServiceName = "TS_"+ ($Service.ServiceName)
            $ServiceName = ($Service.ServiceName)
            

            if ($Service.Current_Working_Folder -ne $null) {
                    $ServiceStatus = Get-Service -Name $WindowsServiceName

                Write-Log "Setting $WindowsServiceName -StartupType Disabled"
                Set-Service -Name $WindowsServiceName -StartupType Disabled
                Write-Log "Stopping $WindowsServiceName"
                   
                if ($ServiceStatus.Status -eq 'running') {
                    Stop-Service $WindowsServiceName -ErrorAction SilentlyContinue -ErrorVariable StopServiceError

                    if ($StopServiceError) {
                        Write-Log -Level Error "$StopServiceError"
                    }
                    else {
                        Write-Log "$WindowsServiceName stopped successfully"
                    }

                }
                   
                if ($ServiceStatus.Status -eq 'stopped') {
                    Write-Log "$ServiceName is already stopped"
                }

            }
            else {
            Write-Log "Service $ServiceName is not installed"
            }

        }
}

function Change-ServiceFolder {
    
    param (
          )
          
        $ServicesToBeInstalled = Get-ServicesToBeInstalled
        
        foreach ($Service in $ServicesToBeInstalled) {
            $WindowsServiceName = "TS_"+ ($Service.ServiceName )
            $ServiceName = $Service.ServiceName
            $NewServicePath = $destinationFolder + $ServiceName + "\" + ($Service.New_Service_Name_And_Version) + "\$ServiceName.Host.exe"
            Write-Log "Changing $WindowsServiceName path to $NewServicePath"

            if($Service.Current_Working_Folder -ne $null) {
                sc.exe config $WindowsServiceName binpath= $NewServicePath
            }
            else{
            Write-Log "Service $ServiceName is not installed"
            }

            
        }    
}

function Install-Service {
    
    param (
          )

        $ServicesToBeInstalled = Get-ServicesToBeInstalled

        foreach ($Service in $ServicesToBeInstalled) {

            $ServiceName = $Service.ServiceName
            $NewWorkingFolder = $Service.New_Working_Folder
            $serviceNewVersion = $Service.New_Version
            $InstallPath = $destinationFolder + $serviceName + "\" + $serviceName + "_" + $serviceNewVersion + "\" + $serviceName + ".Host.exe"
            

            if ($Service.Current_Working_Folder -eq $null) {
                Write-Log "Installing Service $ServiceName"
                sc.exe create "TS_$ServiceName" binpath= $InstallPath start= auto #depend= "service"
            }
        }
}

<#function Start-DependentServices {

    param (
          )

    $WindowsServiceStoppedList = Get-Service -Name "TS_*" | Where-Object {$_.Status -eq "Stopped"}

    Write-Log "Getting dependent services"

        foreach ($WindowsServiceStopped in $WindowsServiceStoppedList) {
                   
            foreach ($dependentService in (Get-Service -Name $WindowsServiceStopped.Name).ServicesDependedOn ) {
                         
                    if
                    ($dependentService.Status -eq "Stopped") {
                    $DependentServiceName = $dependentService.name
                    #Write-Log "Setting -StartupType to automatic on $DependentServiceName"
                    Set-Service -Name $DependentServiceName -StartupType Automatic
                    #Write-Log "Starting $DependentServiceName"
                    Get-Service -Name $DependentServiceName | Start-Service -ErrorAction SilentlyContinue -ErrorVariable DependentServiceStartError
                    }
                    else {
                    #Write-Log $DependentServiceStartError
                    }
                }

        }
}#>

<#function Start-NotDependentServices {

    param (
          )

    $WindowsServiceStoppedList = Get-Service -Name "TS_*" | Where-Object {$_.Status -eq "Stopped"}

    Write-Log "Starting Not Dependent Services"

        foreach ($WindowsServiceStopped in $WindowsServiceStoppedList) {
                 
            $ServiceToBeStarted = $WindowsServiceStopped.name
            Write-Log "Setting -StartupType to automatic on $ServiceToBeStarted"
            Set-Service -Name $ServiceToBeStarted -StartupType Automatic
            Write-Log "Starting $ServiceToBeStarted"
            Get-Service -Name $ServiceToBeStarted | Start-Service -ErrorAction SilentlyContinue -ErrorVariable NotDependentServiceStartError
                
                if ($NotDependentServiceStartError) {
                    Write-Log -Level Error "$NotDependentServiceStartError"
                }
                else {
                    Write-Log [string]$ServiceToBeStarted "started successfully"
                }
        }
                         
}#>

function Start-AllServices {

    param ()

    $ListOfServicesToStart = 
        [ordered]@{
                   TS_DAL=1;
                   TS_PricesRecorder=2;
                   TS_TradingEventsProvider=3;
                   TS_TradingEventsRecorder=4;
                   TS2_AlertsEngine=5;
                   TS_AlertsSender=6;
                   TS2_RiskEngine=7;
                   TS_AccountInfoesProvider=8;
                   TS_TradeReconciler=9;
                   } 


    foreach ($Service in $ListOfServicesToStart.Keys) {
    $ServiceStatus = (Get-Service -Name $Service).Status

        if ($ServiceStatus -eq 'stopped') {
        
            Write-Log "Starting $Service"
            Set-Service $Service -StartupType Automatic
            Start-Service $Service -ErrorAction SilentlyContinue -ErrorVariable ServiceStartError
      
            if ($ServiceStartError) {
            Write-Log -Level Error $ServiceStartError 
            }
            else { 
            Write-Log [string]$Service "started successfully"
            }
        }
    }
}

Extract-GlobalAchive
Get-ServicesToBeInstalled
Check-DeploymentPrerequisites
New-Backup
Extract-Service
Copy-ConfigFiles
Stop-RMServices
Change-ServiceFolder
Install-Service
Start-AllServices

