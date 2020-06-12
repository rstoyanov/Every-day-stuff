#[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\report.xml"
#$transactions = $statement.APAccounts.ArrayOfAPAccounts.APAccount.BankAccount.BankAccountMovements.ArrayOfBankAccountMovements.BankAccountMovement
[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\report.xml"
$transactions = $statement.Items.AccountMovement

### Category list

#Automobile
$autoAnnualCheck = ""
$autoCarWash = ""
$autoEquipment = ""
$autoFuel = "SHELL","OMV","PBZTPETROL","EKO"
$autoInsurance = "47041917220001115","BG11119002606465"
$autoMaintenance = ""
$autoOwnershipTax = ""
$autoParking = ""
$autoPenalty = ""
$autoRegistration = ""
$autoTyres = ""
$autoRoadTax = "E-VINETKA"

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

# Cash Payments
$cash = "АТМ","PHYRE","REVOLUT"

# Drinks
$drinksAlcohol = ""
$drinksCoffee = "SPETEMA"

# Education
$educationBooks = "Audible","CIELA","UDEMY","HELIKON","ORANGE"
$educationOther = ""
$educationTuition = ""

# Family
$family = ""

# Food
$foodGroceries = "BILLA","INMEDIO","FANTASTIKO","FANTASTICO","BALEV","EBAG","T-MARKET","ZELEN","LIDL","KAUFLAND","METRO","RECORD","NewGen","DAHAPNA","INFINITUM"
$foodLunch = "BAKERS","BMS","K-EXPRESS","BG Invest","FAST FIVE","T.N.D.","CHILLBOX","KFC"
$foodResturant = "PETRUS","EDO","MARAYA","HAPPY","SWET","CONFETTI","LA TERRAZZA","RAFFY"

# Gifts
$gifts = "DIMS","ZARIMEX","DOUGLAS","маса","RD Kali","Рали"

# Healthcare
$healthBeauty = ""
$healthEye = "GRAND OPTICS","ZEISS","JOY FASHION"
$healthDental = "D-R RAYCHEV"
$healthMedical = "ADZHIBADEM","SOFIYA MED","PHARM","PROPOLIS","SCS Franchise","EMILIYA ANGELOVA","ACIBADEM","TOKUDA"

# Home
$homeElectronics = ""
$homeFurnishing = "B211 SOFIA","JUMBO","PEPCO"
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
$leisure = "EVENTIM","KINO ARENA","CLUB EXE"

# Personal
$personalCare = "DM 060","LILLY"
$personalClothing = "DEICHMANN","NEW YOURKER","MANIA","CELIO","ZARA","MAT STAR","ESPRIT","TUDORS","VITOSHA BG777","H M/SOFIYA","LCW RETAIL","THE MALL","DECATHLON"
$personalElectronics = "TECHNOPOLIS", "ALIEXPRESS","ARDES","MUSAGENICA"
$personalSoftware = "LINKEDIN","GOOGLE","SYGIC","NAMECHEAP"

# Services 
$serviceGovernment = "SOFIYSKI RAYONEN SAD"
$serviceLawyer = ""
$serviceNotary = ""

# Sport
$sportFitness = "NEXT LEVEL"
$sportMultisport = ""

# Taxes
$taxBank = "Такса"
$taxBankInterest = "Погасяване на дължима"
$taxBankOther = "справка-баланс"
$taxProperty = "EPAY BUDGET"
 
# Transportation
$transportSpark = "Ride Share"
$transportMetro = ""
$transportTaxi = ""

# Vacation
$vacation = "KAVALA","PROMACHONA","PAPPAS","MELISSIS","BOTEVGRAD","VINKOVCI","BEOGRAD","TRUPALE","NOVALJA","V.KOPANIC","OGULIN","JASENICE","KOLAN","MASLENICA","VRCIN",
            "DIMITROVGRAD","IVANJA","NATURA","VELINGRAD","SAMOKOV","BANSKO","Varna","s.Drazhevo"

# Remont Bl. 92
$remontBlok92 = ""



$result = @()

foreach ($t in $transactions) {

    $utime = ([DateTimeOffset] $t.PaymentDateTime).ToUnixTimeMilliseconds()
    $result += New-object psobject -property  @{Amount = $t.Amount;
                                                DateTime = $utime;
                                                PaymentDateTime = $t.PaymentDateTime;
                                                Reason = $t.NarrativeI02;
                                                BankReason = $t.Reason}                                             
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
    elseif ($autoRoadTax | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="RoadTax"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($autoInsurance | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="Insurance"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
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
    # Cash
    elseif ($cash | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Cash"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Drinks 
    elseif ($drinksCoffee  | Where-Object {$r.Reason -match $_ } ) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Drinks";Subcategory="Coffee"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
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
    # Gifts $gifts
    elseif ($gifts | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Gifts"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
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
    # Home  $homeFurnishing
    elseif ($homeFurnishing | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Home";Subcategory="Furnishing"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }   
    elseif ($homeMaintenance | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Home";Subcategory="Maintenance"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    #Leisure $leisure
    elseif ($leisure | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Laisure"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
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
    # Services
    elseif ($serviceGovernment | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Services";Subcategory="Government"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Sport
    elseif ($sportFitness | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Sport";Subcategory="Fitness"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Taxes $taxBankOther
    elseif ($taxBank | Where-Object {$r.BankReason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="Bank"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxBankInterest | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="BankInterest"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxBankOther | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="BankOther"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxProperty | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="Property"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Transport $transportSpark
    elseif ($transportSpark | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Transport";Subcategory="Spark"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Education
    elseif ($educationBooks | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Education";Subcategory="Books"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    # Vacation
    elseif ($vacation | Where-Object {$r.Reason -match $_}) {
        #Write-Influx -Measure moneyflow -Tags @{Category="Vacation"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }
    else {
        Write-Host "Unknown Transaction" -ForegroundColor Yellow
        Write-Host 'Amount:'  $r.Amount -ForegroundColor Yellow
        Write-Host 'Reason:'  $r.Reason -ForegroundColor Yellow
        Write-Host 'Bank Reason:' $r.BankReason -ForegroundColor Yellow
        Write-Host 'Date/Time' $r.PaymentDateTime -ForegroundColor Yellow
        Write-Host ""
        #Write-Influx -Measure moneyflow -Tags @{Category="Unknown";Subcategory="Unknown"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$r.Reason} -Database money -Server $influxAddress -Verbose 
    }    

}