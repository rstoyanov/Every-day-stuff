$var1 = ""
$Street = ""
$Destination = "Alma"
[xml]$SiteAttribute = Get-Content SitesAttributes.xml

foreach( $Site in $SiteAttribute.location.Site){ #this line in your code has issue
    $var1 = $Site.city    
    If ($var1 -match $Destination){
       $NewStreet = $Site.Street
       $NewCity = $Site.city
       $NewPoBox = $site.POBox
       $NewState = $site.State
       $Newzip = $Site.zip
       $NewCountry = $Site.country
       $NewPhone = $Site.OfficePhone
       } 
}