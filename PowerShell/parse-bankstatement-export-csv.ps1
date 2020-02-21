
#[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\report.xml"
#$transactions = $statement.APAccounts.ArrayOfAPAccounts.APAccount.BankAccount.BankAccountMovements.ArrayOfBankAccountMovements.BankAccountMovement
[xml]$statement = Get-Content -Path "C:\Users\radostin.s\Documents\reports\main.xml"
$transactions = $statement.Items.AccountMovement

### Category list

#Automobile
$autoAnnualCheck = ""
$autoCarWash = ""
$autoEquipment = ""
$autoFuel = "SHELL","OMV","PBZTPETROL","EKO"
$autoInsurance = "полица","BG11119002606465"
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
$educationBooks = "Audible","CIELA","HELIKON","ORANGE"
$educationOther = ""
$educationTuition = "UDEMY"

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

# To be sorted
$Unknown = "epay.bg"



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
$resultCSV = @()
$bank = "unicredit bank"

foreach ($r in $result) {
    
    # Creates an object with the fields needed for the CSV.
<#    $property = @{amount = ([float]$r.Amount * -1);
                date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                comment = $r.Reason;
                bank = $bank;
                category = "$category > $subcategory";}
#>
<#    $propertyTax = @{amount = ([float]$r.Amount * -1);
                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                    comment = $r.BankReason;
                    bank = $bank;
                    category = "$category > $subcategory";}
#>    
    # Automobile 
    if ($autoAnnualCheck | Where-Object {$r.Reason -match $_ } ) {
        $category = "Automobile"
        $subcategory = "AnnualCheck"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($autoFuel | Where-Object {$r.Reason -match $_ } ) {
        $category = "Automobile"
        $subcategory = "Fuel"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($autoRoadTax | Where-Object {$r.Reason -match $_ } ) {
        $category = "Automobile"
        $subcategory = "RoadTax"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($autoInsurance | Where-Object {$r.Reason -match $_ } ) {
        $category = "Automobile"
        $subcategory = "Insurance"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Bari 
    elseif ($bariEquipment | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bari"
        $subcategory = "Equipment"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($bariHealth | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bari"
        $subcategory = "Healthcare"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    #Bills 
    elseif ($billsElectricity | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bills"
        $subcategory = "Electricity"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($billsHeating | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bills"
        $subcategory = "Heating"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($billsTvInternet | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bills"
        $subcategory = "Internet"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($billsSOT | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bills"
        $subcategory = "SOT"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($billsWater | Where-Object {$r.Reason -match $_ } ) {
        $category = "Bills"
        $subcategory = "Water"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Cash
    elseif ($cash | Where-Object {$r.Reason -match $_ } ) {
        $category = "Cash"
        $subcategory = "Payments"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Drinks 
    elseif ($drinksCoffee  | Where-Object {$r.Reason -match $_ } ) {
        $category = "Drinks"
        $subcategory = "Coffee"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Education 
    elseif ($educationBooks | Where-Object {$r.Reason -match $_}) {
        $category = "Education"
        $subcategory = "Books"
         $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($educationTuition | Where-Object {$r.Reason -match $_}) {
        $category = "Education"
        $subcategory = "Tuition"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Food
    elseif ($foodGroceries | Where-Object {$r.Reason -match $_ } ) {
        $category = "Food"
        $subcategory = "Groceries"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($foodLunch | Where-Object {$r.Reason -match $_}) {
        $category = "Food"
        $subcategory = "Lunch"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($foodResturant | Where-Object {$r.Reason -match $_}) {
        $category = "Food"
        $subcategory = "Resturant"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Gifts $gifts
    elseif ($gifts | Where-Object {$r.Reason -match $_}) {
        $category = "Gifts"
        $subcategory = "All"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Healthcare
    elseif ($healthEye | Where-Object {$r.Reason -match $_}) {
        $category = "Health"
        $subcategory = "Eyecare"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($healthDental | Where-Object {$r.Reason -match $_}) {
        $category = "Health"
        $subcategory = "Dental"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($healthMedical | Where-Object {$r.Reason -match $_}) {
        $category = "Health"
        $subcategory = "Medical"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Home  $homeFurnishing
    elseif ($homeFurnishing | Where-Object {$r.Reason -match $_}) {
        $category = "Home"
        $subcategory = "Furnishing"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }   
    elseif ($homeMaintenance | Where-Object {$r.Reason -match $_}) {
        $category = "Home"
        $subcategory = "Maintenance"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    #Leisure $leisure
    elseif ($leisure | Where-Object {$r.Reason -match $_}) {
        $category = "Leisure"
        $subcategory = "All"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }   
    # Personal 
    elseif ($personalCare | Where-Object {$r.Reason -match $_}) {
        $category = "Personal"
        $subcategory = "Care"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($personalClothing | Where-Object {$r.Reason -match $_}) {
        $category = "Personal"
        $subcategory = "Clothing"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($personalElectronics | Where-Object {$r.Reason -match $_}) {
        $category = "Personal"
        $subcategory = "Electronics"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($personalSoftware | Where-Object {$r.Reason -match $_}) {
        $category = "Personal"
        $subcategory = "Software"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Services
    elseif ($serviceGovernment | Where-Object {$r.Reason -match $_}) {
        $category = "Service"
        $subcategory = "Government"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Sport
    elseif ($sportFitness | Where-Object {$r.Reason -match $_}) {
        $category = "Sport"
        $subcategory = "Fitness"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Taxes
    elseif ($taxBank | Where-Object {$r.BankReason -match $_}) {
        $category = "Taxes"
        $subcategory = "Bank"
        $resultCSV += New-object psobject -property @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.BankReason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($taxBankInterest | Where-Object {$r.Reason -match $_}) {
        $category = "Taxes"
        $subcategory = "BankInterest"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($taxBankOther | Where-Object {$r.Reason -match $_}) {
        $category = "Taxes"
        $subcategory = "BankOther"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    elseif ($taxProperty | Where-Object {$r.Reason -match $_}) {
        $category = "Taxes"
        $subcategory = "Property"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Transport $transportSpark
    elseif ($transportSpark | Where-Object {$r.Reason -match $_}) {
        $category = "Transport"
        $subcategory = "Spark"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # Vacation
    elseif ($vacation | Where-Object {$r.Reason -match $_}) {
        $category = "Vacation"
        $subcategory = "All"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
    }
    # To be sorted
    elseif ($unknown | Where-Object {$r.Reason -match $_}) {
        $category = "Unknown"
        $subcategory = "All"
        $resultCSV += New-object psobject -property  @{amount = ([float]$r.Amount * -1);
                                                    date = $r.PaymentDateTime.Split("T") | Select-Object -First 1;
                                                    comment = $r.Reason;
                                                    bank = $bank;
                                                    category = "$category > $subcategory";}
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
$path = (Get-Location).path
return $resultCSV | Export-Csv "$path\import_main_expense.csv" -Encoding UTF8
