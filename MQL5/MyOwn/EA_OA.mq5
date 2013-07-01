#property copyright "Copyright 2009-2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input int StopLoss=670;
input int TakeProfit=610;
//---
int count=0;
int   ExtHandle=0;
CSymbolInfo mySymbol;
CTrade myTrade;
CPositionInfo myPosition;
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
int TradingSignal (void)
  {
   MqlRates rt[2];
//--- go trading only for first ticks of new bar
   if(CopyRates(Symbol(),Period(),0,2,rt)!=2)
     {
      Print("CopyRates of ",Symbol()," failed, no history");
      return 0;
     }
   if(rt[1].tick_volume>1)
      return 0;


   double   ao[4];
   if(CopyBuffer(ExtHandle,0,0,4,ao)!=4)
     {
      Print("CopyBuffer from iAO failed, no data");
      return 0;
     }  
   printf("Tick time:"+rt[1].time+" "+DoubleToString(ao[0])+" "+DoubleToString(ao[1])+" "+DoubleToString(ao[2]));

    if((ao[0]>0&&ao[1]>0&&ao[2]>0)&&(ao[1]<ao[0]&&ao[1]<ao[2]))
      return 1;
    if(ao[1]<0&&ao[2]>0)
      return 1;  
      
    if((ao[0]<0&&ao[1]<0&&ao[2]<0)&&(ao[1]>ao[0]&&ao[1]>ao[2]))
      return -1;
    if(ao[1]>0&&ao[2]<0)
      return -1;
      
    return 0;  
    
    

   
//---
  }
  void ClosePosition(ENUM_POSITION_TYPE positionType)
  {
      if(myPosition.Select(Symbol())==true)
      {
         if(myPosition.Symbol()==Symbol())
           {
            //--- Check if we can close this position
           
               if(positionType!=myPosition.PositionType()&&myTrade.PositionClose(Symbol())) //--- Request successfully completed 
                 {
                  printf("An opened position has been successfully closed!!");
                 }
              
              }
       }
  }
  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {

      ulong Magic_No=12345;
      myTrade.SetExpertMagicNumber(Magic_No);
      ulong Deviation=20;
      myTrade.SetDeviationInPoints(Deviation);
      
      mySymbol.Name(Symbol());
         
   
//---
   ExtHandle=iAO(Symbol(),PERIOD_CURRENT);
   
   
   if(ExtHandle==INVALID_HANDLE)
     {
      printf("Error creating Awesome Oscillator indicator");
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//---

      
      int signal=TradingSignal();
      
      if(signal==1)
      {
        
         ClosePosition(POSITION_TYPE_BUY);
         

         mySymbol.RefreshRates();
         printf(mySymbol.Ask());
         // define the input parameters and use the CSymbolInfo class
         // object to get the current ASK/BID price
         double Lots = 0.1;
         // Stoploss must have been defined 
         double SL = mySymbol.Ask()-StopLoss*mySymbol.Point();   
         //Takeprofit must have been defined 
         double TP = mySymbol.Ask() + TakeProfit*mySymbol.Point(); 
         // latest ask price using CSymbolInfo class object
         double Oprice = mySymbol.Ask();
         
         //printf("Buy order place:Oprice-"+DoubleToString(Oprice)+" SL-"+DoubleToString(SL)+" TP-"+DoubleToString(TP));
         // open a buy trade
        // myTrade.PositionOpen(Symbol(),ORDER_TYPE_BUY,Lots,Oprice,SL,TP);
                     
         myTrade.Buy(Lots,Symbol(),Oprice,SL,TP);
      }
      
       if(signal==-1)
      {
         ClosePosition(POSITION_TYPE_SELL);
         mySymbol.RefreshRates();
         // define the input parameters and use the CSymbolInfo class
         // object to get the current ASK/BID price
         double Lots = 0.1;
         // Stoploss must have been defined 
         double SL = mySymbol.Bid()+StopLoss*mySymbol.Point();   
         //Takeprofit must have been defined 
         double TP = mySymbol.Bid() -TakeProfit*mySymbol.Point(); 
         // latest ask price using CSymbolInfo class object
         double Oprice = mySymbol.Bid();
         
         printf("Sell order place:Oprice-"+DoubleToString(Oprice)+" SL-"+DoubleToString(SL)+" TP-"+DoubleToString(TP));
         // open a buy trade
         //myTrade.PositionOpen(Symbol(),ORDER_TYPE_SELL,Lots,Oprice,SL,TP);
         myTrade.Sell(Lots,Symbol(),Oprice,SL,TP);
      }
      
//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
