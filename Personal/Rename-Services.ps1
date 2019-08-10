
$ServiceList = Get-Service -Name MMM* 

foreach ($Service in $ServiceList) {

$ServiceOldName = $Service.Name
$ServiceNewName = $Service.Name -replace "MMM", "TS_"
$GetPath = Get-WmiObject win32_Service | ?{$_.Name -like "*$ServiceOldName*"} | select PathName
$ModifyPath = $GetPath -replace "@{PathName=", ""
$Path = $ModifyPath -replace "}", ""

Stop-Service $ServiceOldName
sc.exe delete $ServiceOldName
sc.exe create "$ServiceNewName" binpath= "$Path" start= auto
}