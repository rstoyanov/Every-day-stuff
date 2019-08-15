1..100 | ForEach { notepad }

measure-command {
Get-Process -name notepad |
ForEach-Object { $_.kill() }
}

Measure-Command {
$processes = Get-Process -Name notepad
foreach ($proc in $processes) {
    $proc.kill()
}
}