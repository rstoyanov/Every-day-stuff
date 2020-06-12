
param(
    [string]$ComputerName
)

foreach ($Comp in $ComputerName) {
    $cs = Get-WmiObject -Class Win32_computersystem -ComputerName $Comp
    $os = Get-WmiObject -Class Win32_operatingsystem -ComputerName $Comp
    $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $Comp
 
    $props = [ordered]@{'ComputerName'=$Comp;
                'OSVersion'=$os.version;
                'SPVersion'=$os.servicepackmajorversion;
                'Mfgr'=$cs.manufacturer;
                'Model'=$cs.model;
                'RAM'=$cs.totalphysicalmemory;
                'BIOSSerial'=$bios.serialnumber
                }
    New-Object -TypeName psobject -Property $props
}