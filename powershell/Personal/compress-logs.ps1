<#Windows PowerShell Code####################################################### 
 .SYNOPSIS  
    Archive Log Files: Manually specify any folder(s) or automatically parse IIS  
    log file folders, group by day/month and archive them with 7-Zip. Verify 
    the archives and delete the original log files. The compressed archive will  
    be about 4.5% (or less) of the size of the original log files. 
 
.DESCRIPTION  
    Archive files by location as defined by one fo the following: 
    - Automatically discover all IIS sites logfile folders using the  
      WebAdministration module 
    - Manually specify target folders 
    - Manually specify a base target folder for recursion to find all subsequent 
      log folders 
 
    Parse through folder contents to find the previous month's or day's  
    files. Archive them, verify the archive and delete the original files.  
    The resulting compressed archive will be about 4.5% (or less) of the size  
    of the original log files. Optionally remove archives older than a user  
    defined number of days. 
             
    This script is best used by setting a scheduled task to run it during  
    off-peak times because the compression process will max out all available  
    cores unless you tell 7-Zip not to do so (in its own settings, not from this 
    script.) 
 
    7-Zip version 15 or higher is required for this script to work. 
    http://www.7-zip.org/download.html 
 
    Important! In Windows Server 2012+ you may need to run this script with  
    administrator privileges and/or remove UAC controls on IIS log file folders 
    to successfully archive them. 
 
    Human readable dates are in the yyyyMMdd format. 
 
    You have a royalty-free right to use, modify, reproduce, and distribute this 
    script file in any way you find useful, provided that you agree to give  
    credit to the creator owner, and you agree that the creator owner has no  
    warranty, obligations, or liability for such use.  
 
.NOTES  
    File Name  : compress-remove-logs.ps1  
    Version    : 2.4.8 
    Date       : 20170406 
    Author     : Bernie Salvaggio 
    Email      : BernieSalvaggio(at)gmail(dot)com 
    Twitter    : @BernieSalvaggio 
    Website    : http://www.BernieSalvaggio.com/ 
    Requires   : PowerShell V2, V3, V4 or V5 
  
###############################################################################> 
 
# Build the base pieces for emailing results 
$ServerName = gc env:computername 
$SmtpClient = new-object system.net.mail.smtpClient 
$MailMessage = New-Object system.net.mail.mailmessage 
$MailMessage.Body = "" 
 
################################################################################ 
####################### BEGIN USER CONFIGURABLE SETTINGS ####################### 
 
# Set to $true if you would like to run the script in Test Mode, which performs  
# all actions as normal but DOES NOT delete the original files you're archiving 
# OR the old archives if you've enabled the setting for removing old archives. 
# Note: Test mode should be run from the command line to see the results of the  
# "-WhatIf" operations. Email messaging/logging is not altered for test mode. 
$TestMode = $true 
 
# Mail server settings. Change according to your environment. 
# You have the option of receiving error notifications via email and/or writing. 
# them to a log file.  
$SmtpClient.Host = "192.0.2.5" 
$MailMessage.from = ($ServerName + "@example.com") 
$MailMessage.To.add("username@example.com") 
$MailMessage.Subject = $ServerName + " Log File Archive Results" 
 
# When should this script email you? 
# "both" -> Email on both success and failure 
# "failure" -> Only email on failure 
# "never" -> Don't send any emails from this script 
# Note: A "failure" could be a hard failure, e.g., can't find the path to 7-Zip, 
#       or a soft failure, e.g., no files found to archive in a specified path. 
$MailMessageDetermination = "both" 
 
# Path to logfile - make sure this script has permissions to write here. 
# Set to "" if you don't want to use a log file. 
$Logfile = "C:\temp\LogfileArchiving-Log.txt" 
 
# Folder for the temp file that stores the list of files for 7-Zip to archive. 
$TempFolder = "C:\temp" 
 
# Path to the 7-Zip executable. 
# Note: 7z.dll must also be in this folder for 7-Zip to work. 
$7z = "C:\Program Files (x86)\7-Zip\7z.exe" 
 
# Select 7-Zip compression method: 
# "zip" -> Traditional zip compression (.zip extension) 
# "ppmd" -> Specialized compression method for text files. Creates a (.7z)   
#        7-Zip archive, which requires 7-Zip to open. Processing is slower  
#        but the resulting archive will be about 50% smaller. 
$CompressionMethod = "ppmd" 
 
# Note: Only required if you set $CompressionMethod = "ppmd" above. 
# How much RAM should PPMd use? (*in MB* max=256, 7-Zip default=24) 
$PPMdRAM = "128" 
 
# If you would like to automatically remove the archives that this script  
# creates, set the following to $true and then define how old the archives  
# should be (in days) to be deleted. 
# Note: This option only deletes .zip or .7z files, depending on the  
#       compression method that you selected above. 
# Note 2: Archive dates are set based on the most recent file's date in the 
#         archive. So if a file date is 20150105 and you set it up below to 
#         delete archives older than 120 days, the archive will be created 
#         and immediately deleted. So you may want to leave this setting as 
#         $false until you've done a few runs and decided what you want to 
#         do with your old archives. 
$RemoveOldArchives = $false 
$RemoveArchivesDaysOld = 120 
 
# Name to begin the filename of the resulting archive. 
$TargetTypeName = "ProgramName-Logs-" 
 
# Archive Date Grouping - Specify how to group the archives 
# "month" -> Archive all past log files by month, excluding the current month 
# "day" ->   Archive all past log files by day, excluding the most recent 2 days  
$ArchiveGrouping = "month" 
 
# Archive Storage Location - Use this variable to specify a single location 
# to save all archives. Subfolders will be created using the unique name  
# assigned to each target. 
# 
# If you prefer that the archives are stored in the same folder as the 
# files being archived, change this line to $ArchiveStorage = "" 
$ArchiveStorage = "C:\ArchiveStorage" 
 
# Extension of files to archive. Only change this variable IF... 
# 1. You're using this script to back up files other than IIS log files, 
# 2. You (below) set $ArchiveFolderSearchMethod= "Manual" or "ManualRecurse" and 
# 3. You (below) manually specify archive targets  
# Make sure you remember the leading period, e.g., ".log" and not "log" 
$FileExtension = ".log" 
 
# How do you want to find/specify the folders for archiving? 
# 
# "IIS" -> Use the Web Administration (IIS) provider to automatically archive  
#          log files for all IIS sites. Requires IIS 7+ 
# "Manual" -> Manually specify target log file folder(s) (in the next section) 
# "ManualRecurse" -> Manually specify a base folder for the script to recurse 
#                    through and build a folder list for archiving. 
$ArchiveFolderSearchMethod = "IIS" 
 
<#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
The following two sections are for manually specifying the folder(s) you want  
this script to search through for files to archive. You can ignore these  
sections if you set $ArchiveFolderSearchMethod = "IIS" 
 
If you're not using this script for IIS logs, set $ArchiveFolderSearchMethod  
(above) to "Manual" or "ManualRecurse" and then specify the log file folders and 
their respective backup folders below (in the corresponding section of course.) 
 
If you use these settings, and modify the $FileExtension variable above, you  
can use this script to archive any folders/files, not just IIS log files. 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#> 
# Manually specify one or more folders for archiving 
if ($ArchiveFolderSearchMethod -eq "Manual") { 
    $Targets = @() 
    # Specify the folder(s) (targets) you want to archive 
    # Duplicate the following four lines for each target you want to archive 
    $Properties = @{ArchiveTargetName="Folder 1"; # Just a friendly name 
                    ArchiveTargetFolder="C:\Program Files\Application\Logs\"} # Remember the trailing \  
    $TempObject = New-Object PSObject -Property $Properties 
    $Targets += $TempObject 
 
    # Example: Adding a second folder 
    #$Properties = @{ArchiveTargetName="Folder 2"; # Just a friendly name 
    #                ArchiveTargetFolder="C:\Program Files\Application 2\Logs\"} # Remember the trailing \  
    #$TempObject = New-Object PSObject -Property $Properties 
    #$Targets += $TempObject 
} 
 
# RECURSE: Manually specify one folder to have the script recurse through it 
# and find all folders with files for archiving. 
if ($ArchiveFolderSearchMethod -eq "ManualRecurse") { 
    $ArchiveFolderRecurseBase = "C:\LogsExample" # No trailing \ needed 
} 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 
######################## END USER CONFIGURABLE SETTINGS ######################## 
################################################################################ 
 
function Send-Email { 
    switch ($MailMessageDetermination) { 
        both { $SmtpClient.Send($MailMessage); break } 
        failure { if ($ErrorTrackerEmail) { $SmtpClient.Send($MailMessage) }; break } 
        never { break } 
        default { $SmtpClient.Send($MailMessage) } 
    } 
} 
 
# Because Test-Path crashes and burns if the value is null 
function TestPath { 
    param([string]$FolderPath) 
 
    if (($FolderPath) -and (Test-Path $FolderPath)) { return $true } 
    else { return $false } 
} 
 
# Test to make sure the log file is writeable 
if ($Logfile) { 
    Try { [io.file]::OpenWrite($Logfile).close() } 
    Catch {  
        $MailMessage.Body += "Error: Could not write to logfile path $Logfile" 
        $ErrorTrackerEmail = $true 
        Send-Email 
        Exit 
    } 
} 
 
$LogDate = get-date -Format "yyyyMMdd" 
 
function Write-Log { 
    param([string]$LogEntry) 
 
    $LogEntry = $LogDate + ": " + $LogEntry 
    $MailMessage.Body += $LogEntry 
    if ($Logfile) { Add-content $Logfile -value $LogEntry.replace("`n","") } 
} 
 
# IIS: Automatically parse IIS log file folders 
if ($ArchiveFolderSearchMethod -eq "IIS") { 
    # Check IIS version and load the WebAdministration module accordingly 
    $iisVersion = Get-ItemProperty "HKLM:\software\microsoft\InetStp"; 
    if ($iisVersion.MajorVersion -ge 7) { 
        if ($iisVersion.MinorVersion -ge 5 -or $iisVersion.MajorVersion -ge 8) { 
            # IIS 7.5 or higher 
            Import-Module WebAdministration  
        } else {  
            if (-not (Get-PSSnapIn | Where {$_.Name -eq "WebAdministration"})) { 
                # IIS 7 
                Add-PSSnapIn WebAdministration 
            } 
        } 
        # Grab a list of the IIS sites 
        $Sites = get-item IIS:\Sites\* 
        $Targets = @() 
        foreach ($Site in $Sites) {  
            # Grab the site's base log file directory  
            $SiteDirectory = $Site.logFile.Directory 
            # That returns %SystemDrive% as text instead of the value of the  
            # env variable, which PoSH chokes on, so replace it correctly 
            $SiteDirectory = $SiteDirectory.replace("%SystemDrive%",$env:SystemDrive) 
            # Set the site's actual log file folder (the W3SVC## or FTPSVC## dir) 
            if ($Site.Bindings.Collection.Protocol -like "*ftp*")  
                 { $SiteLogfileDirectory = $SiteDirectory+"\FTPSVC"+$Site.ID } 
            else { $SiteLogfileDirectory = $SiteDirectory+"\W3SVC"+$Site.ID } 
             
            # Create/Add site name and logfile directory to a hash table, then  
            # feed it into a multi-dimension array 
            $Properties = @{ArchiveTargetName=$Site.Name;  
                            ArchiveTargetFolder=$SiteLogfileDirectory} 
            $TempObject = New-Object PSObject -Property $Properties 
            $Targets += $TempObject 
        } 
    } else { 
        Write-Log "IIS 7 or higher is required to use the WebAdministration SnapIn" 
        $ErrorTrackerEmail = $true 
        Send-Email 
        Exit 
    } 
} 
 
# ManualRecurse: Manually specify a base folder, auto-recurse through for sources 
if ($ArchiveFolderSearchMethod -eq "ManualRecurse") { 
    $Targets = @() 
     # The recursion below won't grab the base folder that was specified in 
    # the settings so it's manually added here. 
    $Properties = @{ArchiveTargetName="Base Archive Folder"; 
                    ArchiveTargetFolder=$ArchiveFolderRecurseBase+"\"} 
    $TempObject = New-Object PSObject -Property $Properties 
    $Targets += $TempObject 
     
    Get-ChildItem $ArchiveFolderRecurseBase -Recurse -Directory | foreach { 
        $Properties = @{ArchiveTargetName=$_.Name; 
                        ArchiveTargetFolder=$_.FullName+"\"} 
        $TempObject = New-Object PSObject -Property $Properties 
        $Targets += $TempObject 
    } 
} 
 
# Get today's date 
$CurrentDate = Get-Date 
 
# Prepping to strip invalid file/folder name characters from $ArchiveTargetName. 
# Really only needed for IIS, because IIS site names could have characters that  
# are invalid for file names. 
$InvalidChars = [io.path]::GetInvalidFileNameChars() 
 
# Set the dates needed for archiving by month or day, depending on what was set 
# for $ArchiveGrouping 
Switch($ArchiveGrouping) { 
    "month" { 
        $ArchiveGroupingString = "{0:yyyy}{0:MM}" 
        $ArchiveDate = $CurrentDate.AddMonths(-1).ToString("yyyyMM") 
    } 
    "day" { 
        $ArchiveGroupingString = "{0:yyyy}{0:MM}{0:dd}" 
        $ArchiveDate = $CurrentDate.AddDays(-2).ToString("yyyyMMdd") 
    } 
    Default { 
        Write-Log "Invalid Archive Grouping selected. You selected '$ArchiveGrouping'. Valid options are month and day." 
        $ErrorTrackerEmail = $true 
        Send-Email 
        Exit 
    } 
} 
 
# Set the date for old archive file removal if that was specified in the settings. 
if ($RemoveOldArchives) {  
    [DateTime]$OldArchiveRemovalDate = $CurrentDate.AddDays(-$RemoveArchivesDaysOld) 
} 
 
# Test the temp folder path to make sure it exists, try to create it if it doesn't. 
if (!(TestPath $TempFolder)) {  
    Try { New-Item $TempFolder -type directory -ErrorAction Stop } 
    Catch {  
        Write-Log "The specified temp folder $TempFolder does not exist, and it couldn't be created." 
        $ErrorTrackerEmail = $true 
        Send-Email 
        Exit 
    } 
} 
# Temp file for archive contents. 
$ArchiveList = "$TempFolder\listfile.txt" 
 
# Temp file to write the 7-Zip verify results, later fed into the email message/log. 
$ArchiveResults = "$TempFolder\archive-results.txt" 
 
# Set some details based on which compression method was selected. 
if ($CompressionMethod -eq "zip") { 
    $ArchiveExtension = ".zip" 
} elseif ($CompressionMethod -eq "ppmd") { 
    $ArchiveExtension = ".7z" 
    # Build the switch to set PPMd as the compression method with the amount of RAM specified in settings. 
    $PPMdSwitch = "-m0=PPMd:mem"+$PPMdRAM+"m" 
} else { 
    Write-Log "Error: Invalid compression method specified. Valid options are zip or ppmd. You specified $CompressionMethod" 
    $ErrorTrackerEmail = $true 
    Send-Email 
    Exit 
} 
 
# Tracker in case no files are found to archive. 
$FilesFound = $false 
 
# Tracker for success or failure so the script knows when to email results. 
$ErrorTrackerEmail = $false 
 
# Test the path to the 7-Zip executable. 
if (!(TestPath $7z)) {  
    Write-Log "Error: 7-Zip not found at $7z" 
    $ErrorTrackerEmail = $true 
    Send-Email 
    Exit 
} 
 
# Test to make sure we're trying to use the right version of 7-Zip (15+). 
# Note: If you're using a beta version of 7-Zip, this check will fail no matter what. 
[single]$7zVersion = (Get-Item $7z).VersionInfo.FileVersion 
if ($7zVersion -lt 15) { 
    Write-Log "Error: 7-Zip version 15 or higher is required by this script. You are running version $7zVersion." 
    $ErrorTrackerEmail = $true 
    Send-Email 
    Exit 
} 
 
# Test the path to the archive storage location, if it has been set. 
if ($ArchiveStorage) {  
    if (!(TestPath $ArchiveStorage)) {  
        Write-Log "Error: The specified archive storage location does not exist at $ArchiveStorage.  
        Please create the requested folder and try again." 
        $ErrorTrackerEmail = $true 
        Send-Email 
        Exit 
    } 
} 
 
################################################################################ 
# Begin looping through all the Targets and do the actual archiving work. 
$TargetsCounter = $Targets.count 
For ($x=0; $x -lt $TargetsCounter; $x++) { 
     
    # Replace invalid file/folder name characters in the $TargetName with dashes. 
    $TargetName = $Targets[$x].ArchiveTargetName -replace "[$InvalidChars]","-" 
    $TargetArchiveFolder = $Targets[$x].ArchiveTargetFolder 
     
    # Check for and create a folder for $TargetName if($ArchiveStorage) 
    if ($ArchiveStorage -ne "") {  
        $ArchiveStorageTarget = $ArchiveStorage+"\"+$TargetName 
        if (!(TestPath $ArchiveStorageTarget)) {  
            New-Item $ArchiveStorageTarget -type directory  
        } 
    } elseif ($ArchiveStorage -eq "") {  
        # Default to keeping log file archives in the log files source folder. 
        $ArchiveStorageTarget = $TargetArchiveFolder 
    } 
     
    # Used for tracking if no files meeting the backup criteria are found. 
    $FilesFound = $false 
     
    Write-Log "------------------------------------------------------------------------------------------`n`n" 
 
    # Check to make sure the $TargetArchiveFolder actually exists. 
    if (!(TestPath $TargetArchiveFolder)) {  
        Write-Log "The requested target archive folder of $TargetArchiveFolder does not exist. Please check the requested location and try again.`n`n"  
        $ErrorTrackerEmail = $true 
    } else { 
        # Directory list, minus folders, last write time <= archive date, group files by month or day as defined in settings. 
        dir $TargetArchiveFolder | where {  
            !$_.PSIsContainer -and $_.extension -eq $FileExtension -and $ArchiveGroupingString -f $_.LastWriteTime -le $ArchiveDate  
        } | group {  
            $ArchiveGroupingString -f $_.LastWriteTime  
        } | foreach { 
            $FilesFound = $true 
             
            # Generate the list of files to compress. 
            $_.group | foreach {$_.fullname} | out-file $ArchiveList -encoding utf8 
             
            # Create the full path of the archive file to be created. 
            $ArchiveFileName = $ArchiveStorageTarget+"\"+$TargetTypeName+$_.name+$ArchiveExtension 
             
            # Archive the list of files. 
            if ($CompressionMethod -eq "zip") { 
                $null = & $7z a -tzip -mx8 -y -stl $ArchiveFileName `@$ArchiveList 
            } elseif ($CompressionMethod -eq "ppmd") { 
                $null = & $7z a -t7z -stl $PPMdSwitch $ArchiveFileName `@$ArchiveList 
            }  
            # Check if the operation succeeded. 
            if ($LASTEXITCODE -eq 0) { 
                # If it succeeded, double check with 7-Zip's Test feature. 
                $null = & $7z t $ArchiveFileName | out-file $ArchiveResults 
                if ($LASTEXITCODE -eq 0) { 
                    # Success, write the contents of the verify command to the log/email. 
                    foreach ($txtLine in Get-Content $ArchiveResults) { 
                        Write-Log "$txtLine `n" 
                    } 
                    Write-Log "`n`n" 
                    if ($TestMode) { 
                        # Show what files would be deleted. 
                        $_.group | Remove-Item -WhatIf 
                    } else { 
                        # Delete the original files. 
                        $_.group | Remove-Item 
                    } 
                } else { 
                    # The verify of the archive failed. 
                    Write-Log "`nThere was an error verifying the 7-Zip  
                        archive $ArchiveFileName`n`n" 
                    $ErrorTrackerEmail = $true 
                } 
            } else { 
                # Creating the archive failed. 
                Write-Log "`nThere was an error creating the 7-Zip  
                    archive $ArchiveFileName`n`n" 
                $ErrorTrackerEmail = $true 
            } 
        } 
         
        if (!$FilesFound) { 
            # No files found to parse. 
            Write-Log "Info: No files found to archive in $TargetArchiveFolder`n`n" 
            $ErrorTrackerEmail = $true 
        } 
         
        # Test if temp files exist and remove them. 
        if (TestPath $ArchiveList) { Remove-Item $ArchiveList } 
        if (TestPath $ArchiveResults) { Remove-Item $ArchiveResults } 
    } 
} 
 
################################################################################ 
# Remove old archives if enabled in settings. 
if ($RemoveOldArchives) { 
    # Loop through just like we do to archive files. 
    For ($x=0; $x -lt $TargetsCounter; $x++) { 
        # Replace invalid file/folder name characters in the target name with dashes. 
        $TargetName = $Targets[$x].ArchiveTargetName -replace "[$InvalidChars]","-" 
        $TargetArchiveFolder = $Targets[$x].ArchiveTargetFolder 
         
        # If a single target folder for archives has been defined... 
        if ($ArchiveStorage) { $ArchiveStorageTarget = $ArchiveStorage+"\"+$TargetName }  
        # If archives are being stored in the logs source folder... 
        else { $ArchiveStorageTarget = $TargetArchiveFolder } 
 
        # Grab all files that aren't folders, last write time older than specified in settings, with a .zip extension. 
        dir $ArchiveStorageTarget | where {!$_.PSIsContainer} | where {$_.LastWriteTime -lt $OldArchiveRemovalDate -and $_.extension -eq $ArchiveExtension } | foreach {  
            if ($TestMode) { Remove-Item "$ArchiveStorageTarget\$_" -WhatIf } 
            else { Remove-Item "$ArchiveStorageTarget\$_" } 
            # Because it displayed as text when including it in the $MailMessage below without first putting it in a new variable... 
            $FileLastWriteTime = $_.LastWriteTime 
            # Write the results to the log/email. 
            Write-Log "Old archive file removed`nPath/Name: $ArchiveStorageTarget\$_ `nDate: $FileLastWriteTime `n`n" 
        } 
    } 
} 
 
# Send out the results. 
Send-Email 