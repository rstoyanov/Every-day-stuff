### Video series https://www.youtube.com/watch?v=OVECk9GqSlc&ab_channel=JacobAmaral

# Imports
import threading
import ibapi
from ibapi.client import EClient
from ibapi.wrapper import EWrapper
#
from ibapi.contract import Contract
from ibapi.order import *
import threading
import time

#Vars

# Class for Interactive Brokers Connection
class IBApi(EWrapper,EClient):
    def __init__(self):
            EClient.__init__(self,self)

    # Listen for realtime bars
    def realtimeBar(self,reqId,time,open_,high,low,close,volume,wap,count):
        super().realtimeBar(reqId,time,open_,high,low,close,volume,wap,count)
        try: 
            bot.onBarUpdate(reqId,time,open_,high,low,close,volume,wap,count)
        except Exception as e:
                print(e)
    def error(self, id, errorCode, errorMsg):
            print(errorCode)
            print(errorMsg)
#Bot Logic
class Bot:
    ib = None
    def __init__(self):
        # Connect to IB TWS on init
        # Prerequisites: in TWS Global Configuration/API tick "Enable ActiveX.." and untick "Read-Only API"
        # Check the port number in Global Configuration/API
        self.ib = IBApi()
        self.ib.connect ("127.0.0.1",7497,1)
        ib_thread = threading.Thread(target=self.run_loop, daemon=True) #This will allow me to separate my ibsockets on a separate threads
        ib_thread.start()
        time.sleep(1) #sleeps for 1 sec to skip messages that pop up
        # Get symbol info
        symbol = input("Enter the symbol you want to trade : ")
        # Create our IB Contract object
        contract = Contract() # Creates contract object
        contract.symbol = symbol.upper()
        contract.secType = "STK" # Sets the security type to Stocks
        contract.exchange = "SMART" # Routes to the best exchage
        contract.currency = "USD"
        # Request real time market data
        self.ib.reqRealTimeBars(0,contract,5,"TRADES",1,[])
        
    # Listen to socket in seperate thread
    def run_loop(self):
        self.ib.run()

    # Pass realtime bar data back to our bot object
    def onBarUpdate(self,reqId,time,open_,high,low,close,volume,wap,count):
        print(reqId)

# Start Bot
bot = Bot()

 