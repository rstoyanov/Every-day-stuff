$oldDomains = "cbtnuggets.com", "gmail.com", "company.com"
$newDomains = "nuggetlab.com", "outlook.com", "company.local"

$emails = 'don@cbtnuggets.com',
          'joe@gmail.com',
          'fred@company.com'

foreach ($email in $emails) {
    for ([int]$x = 0 ; $x -lt $oldDomains.Count ; $x++) {
        $email = $email -replace $oldDomains[$x],$newDomains[$x]
    }
    Write-Output $email
}