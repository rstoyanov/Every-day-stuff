$serviceList = get-childitem "C:\Install\PS\" -recurse | where {$_.extension -eq ".rar"} | % {$_.BaseName}

foreach ($service in $serviceList) {
    Get-Service -Name $service | Stop-Service
    Start-Sleep 5
    Set-Service -Name $service -StartupType Manual
}
