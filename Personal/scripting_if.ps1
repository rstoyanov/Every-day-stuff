$procs = get-process

if ($procs.count -gt 100) {
    Write-Host "You have a lot of processes"
}  elseif ($procs.count -lt 5) {
   Write-Host "Very few processes!"
}  elseif ($procs[0].Name -like 'a*') {
    Write-Host "The first process starts with A"
}  else {
    Write-Host "Less than 100 processes!"
}
