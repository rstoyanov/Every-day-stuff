$servers = @(
             "esd-hv2",
             "esd-hv3",
             "esd-hv5",
             "esd-hv7",
             "esd-hv8",
             "esd-hv11",
             "esd-hv15",
             "esd-hv16",
             "esd-hv17",
             "esd-hv18",                
             "esd-hv19",
             "esd-hv20",
             "esd-hv21",
             "esd-hv22",
             "esd-hv23",
             "esd-hv24",
             "esd-hv25",
             "esd-hv26",
             "esd-hv27",
             "esd-hv28",
             "esd-hv29",
             "esd-hv30",
             "esd-hv31",
             "esd-hv32",
             "esd-hv33")

 $testservers = @("esd-hv1",
             "esd-hv10")
  

$credentials = Get-Credential  

foreach ($s in $servers) {
    Write-Host "Processing $s"
    $session = New-PSSession -ComputerName $s -Credential $credentials
    Invoke-Command -Session $session -ScriptBlock {
        
        if (Get-Service "telegraf") {
            Write-Host "Telegraf Service is installed on host" -ForegroundColor Green
        }
        else {
            Write-Host "Telegraf service is not installed on host" -ForegroundColor Yellow
        }
    }
    Remove-PSSession $session
}

