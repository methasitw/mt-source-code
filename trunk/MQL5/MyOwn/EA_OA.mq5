#property copyright "Copyright 2009-2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input int StopLoss=100;
input int TakeProfit=100;
//---
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


   double   ao[3];
   if(CopyBuffer(ExtHandle,0,0,3,ao)!=3)
     {
      Print("CopyBuffer from iAO failed, no data");
      return 0;
     }

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
               else
                 {
                  Alert("The position close request could not be completed - error: ",
                       myTrade.ResultRetcodeDescription());
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
         

         mySymbol.Refresh();
         // define the input parameters and use the CSymbolInfo class
         // object to get the current ASK/BID price
         double Lots = 0.1;
         // Stoploss must have been defined 
         double SL = mySymbol.Ask()-StopLoss*mySymbol.Point();   
         //Takeprofit must have been defined 
         double TP = mySymbol.Ask() + TakeProfit*mySymbol.Point(); 
         // latest ask price using CSymbolInfo class object
         double Oprice = mySymbol.Ask();
         
         // open a buy trade
         myTrade.PositionOpen(Symbol(),ORDER_TYPE_BUY,Lots,
                     Oprice,SL,TP);
      }
      
       if(signal==-1)
      {
         ClosePosition(POSITION_TYPE_SELL);
         mySymbol.Refresh();
         // define the input parameters and use the CSymbolInfo class
         // object to get the current ASK/BID price
         double Lots = 0.1;
         // Stoploss must have been defined 
         double SL = mySymbol.Bid()+StopLoss*mySymbol.Point();   
         //Takeprofit must have been defined 
         double TP = mySymbol.Bid() -TakeProfit*mySymbol.Point(); 
         // latest ask price using CSymbolInfo class object
         double Oprice = mySymbol.Bid();
         // open a buy trade
         myTrade.PositionOpen(Symbol(),ORDER_TYPE_SELL,Lots,
                     Oprice,SL,TP);
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
