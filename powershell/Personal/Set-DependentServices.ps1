# List Of Services and their dependent services

#$AccountInfoesProvider /
$AlertsEngine = "TS_DAL/TS_PricesRecorder"
#$AlertsSender /
#$ServiceDAL /
#$PricesRecorder /
$RiskEngine = "TS_DAL/TS_PricesRecorder/TS_TradingEventsProvider"
$TradeReconciler = "TS_RiskEngine/TS_TradingEventsProvider"
#TradingEventsProvider /
$TradingEventsRecorder = "TS_TradingEventsProvider"



#AlertsEngine Dependencies

$AlertsEngineDependencies = 
    @(
    "$AlertsEngine"
    )

#RiskEngine Dependencies

$RiskEngineDependencies = 
    @(
    "$RiskEngine"
    )

#TradeReconciler Dependencies

$TradeReconcilerDependencies = 
    @(
    "$TradeReconciler"
    )

#TradingEventsRecorder Dependencies

$TradingEventsRecorderDependencies = 
    @(
    "$TradingEventsRecorder"
    )



#Setting dependencies

sc.exe config "TS_AlertsEngine"             depend= $AlertsEngineDependencies
sc.exe config "TS_RiskEngine"               depend= $RiskEngineDependencies
sc.exe config "TS_TradeReconciler"          depend= $TradeReconcilerDependencies
sc.exe config "TS_TradingEventsRecorder"    depend= $TradingEventsRecorderDependencies




