#Create a local account

$computername = [system.net.dns]:: GetHostName() 

Function create-user { 

    param(
            $Computer, 
            $username, 
            $password
         ) 

$ADSI = [ADSI]"WinNT://$Computer" 
$user = $ADSI.Create("User", $username) 
$user.setpassword("$Password") 
$user.setinfo() 

}

#create-user $computername "svcLocalAccount" "P@ssw0rd"


#Delete User

Function delete-user { 

    param(
            $Computer, 
            $username
         ) 
    
    $ADSI = [ADSI]" WinNT://$Computer" 
    $ADSI.Delete("user", "$username") 
    
} 

#delete-user $ computername "remLocalAccount"

