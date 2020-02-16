[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\report.xml"
$transactions = $statement.APAccounts.ArrayOfAPAccounts.APAccount.BankAccount.BankAccountMovements.ArrayOfBankAccountMovements.BankAccountMovement

### Category list

#Automobile
$autoAnnualCheck = ""
$autoCarWash = ""
$autoEquipment = ""
$autoFuel = "SHELL","OMV","PBZTPETROL","EKO"
$autoInsurance = ""
$autoMaintenance = ""
$autoOwnershipTax = ""
$autoParking = ""
$autoPenalty = ""
$autoRegistration = ""
$autoTyres = ""

# Bari
$bariEquipment = "PET NET","ZOOMALL"
$bariFood = ""
$bariHealth = "GREEN DO"

# Bills
$billsCableTv = ""
$billsElectricity = "CEZ ELECTRO"
$billsGSM = ""
$billsHeating = "TOPLOFIKACIA"
$billsTvInternet = "VIVACOM"
$billsSOT = "SOT 161"
$billsTelephone = ""
$billsWater = "SOFIYSKA VODA"
$billEntrance = ""

# Drinks
$drinksAlcohol = ""
$drinksCoffee = ""

# Education
$educationBooks = "Audible","CIELA","UDEMY"
$educationOther = ""
$educationTuition = ""

# Family
$family = ""

# Food
$foodGroceries = "BILLA","INMEDIO","FANTASTIKO","FANTASTICO","BALEV","EBAG","T-MARKET","ZELEN","LIDL","KAUFLAND","METRO","RECORD"
$foodLunch = "BAKERS","BMS","K-EXPRESS","BG Invest","FAST FIVE"
$foodResturant = "PETRUS","EDO","MARAYA","HAPPY","SWET","CONFETTI"

# Gifts
$gifts = ""

# Healthcare
$healthBeauty = ""
$healthEye = "GRAND OPTICS","ZEISS","JOY FASHION"
$healthDental = "D-R RAYCHEV"
$healthMedical = "ADZHIBADEM","SOFIYA MED","PHARM","PROPOLIS"

# Home
$homeElectronics = ""
$homeFurnishing = ""
$homeMaintenance = "MAYSTOR","MAISTOR","MAGAZIN VAKAREL","MR.BRICOLAGE","PRAKTIKER","CAFEMAG"

# Income
$incomeBonus = ""
$incomeFoodVauchers = ""
$incomeInvestment = ""
$incomeOther = ""
$incomeSalary = ""

# Investments
$investmentRealEstate = ""

# Leisure
$leisure = "EVENTIM","KINO ARENA",

# Personal
$personalCare = "DM 060","LILLY"
$personalClothing = "DEICHMANN","NEW YOURKER","MANIA","CELIO","ZARA","MAT STAR","ESPRIT","TUDORS"
$personalElectronics = "TECHNOPOLIS", "ALIEXPRESS"
$personalSoftware = "LINKEDIN","GOOGLE","SYGIC","NAMECHEAP"

# Services 
$serviceGovernment = "SOFIYSKI RAYONEN SAD"
$serviceLawyer = ""
$serviceNotary = ""

# Sport
$sportFitness = "NEXT LEVEL"
$sportMultisport = ""

# Taxes
$taxBank = ""
$taxProperty = "EPAY BUDGET"

# Transportation
$transportSpark = "Ride Share"
$transportMetro = ""
$transportTaxi = ""

# Vacation
$vacation = ""

# Remont Bl. 92
$remontBlok92 = ""



$result = @()

foreach ($t in $transactions) {

    $utime = ([DateTimeOffset] $t.PaymentDateTime).ToUnixTimeMilliseconds()
    $result += New-object psobject -property  @{Amount = $t.AmountLocalCCY;
                                                DateTime = $utime;
                                                Reason = $t.NarrativeI02}                                             
}

#return $result

### Assign a category to a record.

foreach ($r in $result) {
    
    # Automobile
    if ($autoAnnualCheck | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="AnnualCheck"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($autoFuel | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="Fuel"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Bari 
    elseif ($bariEquipment | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bari";Subcategory="Equipment"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($bariHealth | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bari";Subcategory="Health"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    #Bills 
    elseif ($billsElectricity | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Electricity"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsHeating | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Heating"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsTvInternet | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="TvInternet"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsSOT | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="SOT"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsWater | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Water"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Food
    elseif ($foodGroceries | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Groceries"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($foodLunch | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Lunch"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($foodResturant | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Resturant"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Healthcare
    elseif ($healthEye | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Eyecare"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($healthDental | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Dental"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($healthMedical | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Medical"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Home 
    elseif ($homeMaintenance | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Home";Subcategory="Maintenance"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Personal 
    elseif ($personalCare | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Care"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalClothing | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Clothing"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalElectronics | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Electronics"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalSoftware | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Software"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Education
    elseif ($educationBooks | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Education";Subcategory="Books"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    else {
        Write-Host "Unknown Transaction" -ForegroundColor Yellow
        Write-Host 'Reason is' + $r.Reason -ForegroundColor Yellow
        #Write-Influx -Measure moneyflow -Tags @{Category="Unknown";Subcategory="Unknown"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }    

}