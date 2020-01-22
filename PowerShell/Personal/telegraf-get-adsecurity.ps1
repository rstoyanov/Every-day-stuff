function Get-ADSecurity{
    $hostname = (Get-ADDomainController).domain

    ### OverAll AD Statistics total: ###

    $ADAccountDisabled = (Search-ADAccount -AccountDisabled).count
    $ADCountLockedOut = (Search-ADAccount -LockedOut).count
    $ADCountPasswordExpired = (Search-ADAccount -PasswordExpired).count
    $pwdNeverExp = (Get-ADUser -Filter * -Properties passwordneverexpires).count

    ### Passowrd resets per user ###
    $dte = (Get-Date).AddMinutes(-10)
    $PwdUsers = Get-ADUser -Filter 'passwordlastset -gt $dte' -Properties passwordlastset, passwordneverexpires | Sort-Object name | Select-Object Name, passwordlastset
    $counts = ($PwdUsers.Name).count

    foreach ($PwdUser in $PwdUsers) {
    $pwdResetTime = $PwdUser.passwordlatestset
    $pwdResetTime = ([DateTimeOffset] $pwdResetTime).ToUnixTimeMilliseconds()
    $PwdUser = $PwdUser.Name

    #remove spaces - they are not allowed in influxdb
    $group = $group -replace '\s','-'
    $PwdUser = $PwdUser -replace '\s','-'
    $hostname = $hostname -replace '\.','-'
    Write-Host "ad_accounts,host=$hostname,ad_value=PasswordLastSet,instance=$PwdUser status=1,pwdLastSetTime=$pwdResetTime"
    }

    #Write-Host "ad_accounts,host=$hostname,ad_value=ADAccountDisabled total_=$ADAccountDisabled"
    Write-Influx -Measure ad_stats -Tags @{Hostname=$hostname} -Metrics @{ADAccountDisabled=$ADAccountDisabled; 
                                                                          ADCountLockedOut=$ADCountLockedOut;
                                                                          ADCountPwdExpired=$ADCountPasswordExpired;
                                                                          PasswordLastSet=$counts;
                                                                          ADpwdNeverExp=$pwdNeverExp;
                                                                          
                                                                          } -Database telegraf -Server http://10.31.0.31:8086 -Verbose

}

Get-ADSecurity