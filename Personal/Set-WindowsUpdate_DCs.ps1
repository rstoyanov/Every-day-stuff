$WUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$WUSettings.NotificationLevel=3
$WUSettings.ScheduledInstallationDay=7
$WUSettings.ScheduledInstallationTime=1
$WUSettings.Save()