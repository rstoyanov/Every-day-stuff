#[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\report.xml"
#$transactions = $statement.APAccounts.ArrayOfAPAccounts.APAccount.BankAccount.BankAccountMovements.ArrayOfBankAccountMovements.BankAccountMovement
[xml]$statement = Get-Content -Path "C:\Scripts\bank\report.xml"
$transactions = $statement.Items.AccountMovement
$records = @()

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
$educationBooks = "Audible","CIELA","UDEMY","HELIKON","ORANGE","AMZN Digital"
$educationOther = ""
$educationTuition = ""
$tradingCourses = "DANIELIRISH"

# Family
$family = ""

# Food
$foodGroceries = "BILLA","INMEDIO","FANTASTIKO","FANTASTICO","BALEV","EBAG","T-MARKET","ZELEN","LIDL","KAUFLAND","METRO","RECORD","NewGen","DAHAPNA","INFINITUM"
$foodLunch = "BAKERS","BMS","K-EXPRESS","BG Invest","FAST FIVE","T.N.D.","CHILLBOX","KFC","Philly Vibe"
$foodResturant = "PETRUS","EDO","MARAYA","HAPPY","SWET","CONFETTI","LA TERRAZZA","RAFFY","DOMINOS"

# Gifts
$gifts = "DIMS","ZARIMEX","DOUGLAS","маса","RD Kali","Рали","GRABO","RD Iliya"

# Healthcare
$healthBeauty = ""
$healthEye = "GRAND OPTICS","ZEISS","JOY FASHION"
$healthDental = "D-R RAYCHEV","DENTAL"
$healthMedical = "ADZHIBADEM","SOFIYA MED","PHARM","PROPOLIS","SCS Franchise","EMILIYA ANGELOVA","ACIBADEM","TOKUDA","MARIYKA ZHAYGAROVA"

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
$taxBank = "Такса","NOTIF ANNUAL"
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
    $date = $r.PaymentDateTime
    $amount = $r.Amount
    $notes = $r.Reason

    Write-Host ""

    # Automobile 
    if ($autoAnnualCheck | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Automobile,AnnualCheck,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="AnnualCheck"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($autoFuel | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Automobile,Fuel,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="Fuel"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($autoRoadTax | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Automobile,RoadTax,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="RoadTax"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($autoInsurance | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Automobile,Insurance,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Automobile";Subcategory="Insurance"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Bari 
    elseif ($bariEquipment | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bari,Equipment,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bari";Subcategory="Equipment"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($bariHealth | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bari,Health,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bari";Subcategory="Health"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    #Bills 
    elseif ($billsElectricity | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bills,Electricity,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Electricity"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsHeating | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bills,Heating,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Heating"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsTvInternet | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bills,TvInternet,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="TvInternet"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsSOT | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bills,SOT,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="SOT"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($billsWater | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Bills,Water,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Bills";Subcategory="Water"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Cash
    elseif ($cash | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Cash, ,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Cash"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Drinks 
    elseif ($drinksCoffee  | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Drinks,Coffee,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Drinks";Subcategory="Coffee"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Food
    elseif ($foodGroceries | Where-Object {$notes -match $_ } ) {
        $records += "$date,$amount,Food,Groceries,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Groceries"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($foodLunch | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Food,Lunch,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Lunch"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($foodResturant | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Food,Resturant,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Food";Subcategory="Resturant"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Gifts $gifts
    elseif ($gifts | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Gifts, ,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Gifts"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Healthcare
    elseif ($healthEye | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Healthcare,Eyecare,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Eyecare"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($healthDental | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Healthcare,Dental,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Dental"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($healthMedical | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Healthcare,Medical,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Healthcare";Subcategory="Medical"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Home  $homeFurnishing
    elseif ($homeFurnishing | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Home,Furnishing,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Home";Subcategory="Furnishing"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }   
    elseif ($homeMaintenance | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Home,Maintenance,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Home";Subcategory="Maintenance"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    #Leisure $leisure
    elseif ($leisure | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Laisure, ,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Laisure"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }   
    # Personal 
    elseif ($personalCare | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Personal,Care,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Care"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalClothing | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Personal,Clothing,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Clothing"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalElectronics | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Personal,Electronics,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Electronics"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($personalSoftware | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Personal,Software,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Personal";Subcategory="Software"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Services
    elseif ($serviceGovernment | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Services,Government,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Services";Subcategory="Government"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Sport
    elseif ($sportFitness | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Sport,Fitness,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Sport";Subcategory="Fitness"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Taxes $taxBankOther
    elseif (($taxBank | Where-Object {$r.BankReason -match $_}) -or ($taxBank | Where-Object {$notes -match $_})) {
        $records += "$date,$amount,Tax,Bank,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="Bank"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxBankInterest | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Tax,BankInterest,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="BankInterest"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxBankOther | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Tax,BankOther,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="BankOther"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($taxProperty | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Tax,Property,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Tax";Subcategory="Property"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Transport $transportSpark
    elseif ($transportSpark | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Transport,Spark,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Transport";Subcategory="Spark"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Education
    elseif ($educationBooks | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Education,Books,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Education";Subcategory="Books"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    elseif ($tradingCourses| Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Trading,Courses,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Education";Subcategory="Books"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    # Vacation
    elseif ($vacation | Where-Object {$notes -match $_}) {
        $records += "$date,$amount,Vacation, ,$notes"
        #Write-Influx -Measure moneyflow -Tags @{Category="Vacation"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }
    else {
        $records += "$date,$amount,Unknown, ,$notes"
        Write-Host "Unknown Transaction" -ForegroundColor Yellow
        Write-Host 'Amount:'  $r.Amount -ForegroundColor Yellow
        Write-Host 'Reason:'  $notes -ForegroundColor Yellow
        Write-Host 'Bank Reason:' $r.BankReason -ForegroundColor Yellow
        Write-Host 'Date/Time' $r.PaymentDateTime -ForegroundColor Yellow
        Write-Host ""
        #Write-Influx -Measure moneyflow -Tags @{Category="Unknown";Subcategory="Unknown"} -Metrics @{Amount=$r.Amount;DateTime=$r.DateTime;Reason=$notes} -Database money -Server $influxAddress -Verbose 
    }    

}
$records | Out-File "C:\Scripts\bank\import.csv"
