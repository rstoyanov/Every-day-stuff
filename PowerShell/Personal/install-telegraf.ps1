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

<# $testservers = @("esd-hv1",
             "esd-hv10")
#>    

$credentials = Get-Credential  
$source = "\\sof-storage\SBTech\IT\APPS\telegraf-hyper-v"

foreach ($s in $servers) {

    $session = New-PSSession -ComputerName $s -Credential $credentials
    Copy-Item -Path $source -ToSession $session -Destination "C:\Program Files" -Recurse

    Invoke-Command -Session $session -ScriptBlock {

        & 'C:\Program Files\telegraf-hyper-v\telegraf.exe' --service install --config 'C:\Program Files\telegraf-hyper-v\telegraf.conf'
        Start-Service "telegraf"
    }

    Remove-PSSession $session
}


