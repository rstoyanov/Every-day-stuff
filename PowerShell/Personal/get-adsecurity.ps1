### Global Variables

# InfluxDB Server Address
$influxAddress = "http://10.31.0.31:8086"

# Domain
$hostname = (Get-ADDomainController).domain

### Install InfluxDB Powershell module if not present
if (!(Get-InstalledModule -Name "Influx")) {

    Install-Module Influx -Scope CurrentUser -Force
}

function Get-ADStats{
    


    ### OverAll AD Statistics total:
    $ADAccountDisabled = (Search-ADAccount -AccountDisabled).count
    $ADCountLockedOut = (Search-ADAccount -LockedOut).count
    $ADCountPasswordExpired = (Search-ADAccount -PasswordExpired).count
    $pwdNeverExp = (Get-ADUser -Filter * -Properties passwordneverexpires).count

    Write-Influx -Measure ad_stats -Tags @{Domain=$hostname} -Metrics @{ADAccountDisabled=$ADAccountDisabled; 
        ADCountLockedOut=$ADCountLockedOut;
        ADCountPwdExpired=$ADCountPasswordExpired;
        ADpwdNeverExp=$pwdNeverExp;
        } -Database telegraf -Server $influxAddress -Verbose

}

function Get-ADPwdReset {

      ### Passowrd resets per user
      $dte = (Get-Date).AddMinutes(-60)
      $PwdUsers = Get-ADUser -Filter {passwordlastset -gt $dte} -Properties passwordlastset, passwordneverexpires | Sort-Object SamAccountName | Select-Object SamAccountName, passwordlastset
      $counts = ($PwdUsers.SamAccountName).count
  
      foreach ($PwdUser in $PwdUsers) {
      $pwdResetTime = $PwdUser.passwordlastset
      $pwdResetTime = ([DateTimeOffset] $pwdResetTime).ToUnixTimeMilliseconds()
      $PwdUser = $PwdUser.SamAccountName
  
      #remove spaces - they are not allowed in influxdb
      $group = $group -replace '\s','-'
      $PwdUser = $PwdUser -replace '\s','-'
  
  Write-Influx -Measure ad_pwdreset -Tags @{Domain=$hostname} -Metrics @{User=$PwdUser; 
                                                                           Status=1;
                                                                           PwdLastSetTime=$pwdResetTime
                                                                           } -Database telegraf -Server $influxAddress -Verbose 
  
      }

}

function Get-ADAdmins {

    ### Members of Domain Admins
    $DomainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName

    ### Remove unused characters and spaces
    $DomainAdmins = $DomainAdmins -replace '@{SamAccountName=', ''
    $DomainAdmins = $DomainAdmins -replace '}',''

    foreach ($User in $DomainAdmins) {

        Write-Influx -Measure ad_admins -Tags @{Domain=$hostname; Role="DomainAdmin"; User_tag=$User} -Metrics @{User=$User; AdminType="DomainAdmin"} -Database telegraf -Server $influxAddress -Verbose
    }

    ### Members of Enterprise Admin
    $EnterpriseAdmins = Get-ADGroupMember -Identity "Enterprise Admins" | Select-Object SamAccountName

    ### Remove unused characters and spaces

    $EnterpriseAdmins = $EnterpriseAdmins -replace '@{SamAccountName=', ''
    $EnterpriseAdmins = $EnterpriseAdmins -replace '}',''

    foreach ($User in $EnterpriseAdmins) {

        Write-Influx -Measure ad_admins -Tags @{Domain=$hostname; Role="EnterpriseAdmin";User_tag=$User} -Metrics @{User=$User; AdminType="EnterpriseAdmin"} -Database telegraf -Server $influxAddress -Verbose
    }

}

function Get-ADUserCreated {

    ### Get recently created users
    $dte = (Get-Date).AddMinutes(-60)
    $usersCreated = Get-ADUser -Filter {whenCreated -ge $dte} -Properties whenCreated | Sort-Object name| Select-Object SamAccountName, whenCreated 



    foreach ($User in $usersCreated) {
        $createdTime = $User.whenCreated 
        $createdTime = ([DateTimeOffset] $createdTime).ToUnixTimeMilliseconds()
        $User = $User.SamAccountName
    
    Write-Influx -Measure ad_users -Tags @{Domain=$hostname} -Metrics @{User=$User; CreatedTime=$createdTime} -Database telegraf -Server $influxAddress -Verbose
    }

}

Get-ADStats
Get-ADPwdReset
Get-ADAdmins
Get-ADUserCreated 



