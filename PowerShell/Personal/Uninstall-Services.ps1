$services = Get-Service -name TS_*

foreach ($service in $services) {
    $servicename = $service.Name
    sc.exe delete $servicename
    }