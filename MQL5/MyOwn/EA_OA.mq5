#property copyright "Copyright 2009-2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input double MaximumRisk        = 0.02;    // Maximum Risk in percentage
input double DecreaseFactor     = 3;       // Descrease factor
input int    MovingPeriod       = 12;      // Moving Average period
input int    MovingShift        = 6;       // Moving Average shift
//---
int   ExtHandle=0;
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
   if(CopyBuffer(ExtHandle,0,0,3,ao)!=1)
     {
      Print("CopyBuffer from iAO failed, no data");
      return 0;
     }
     else
     {
      printf("Get AO data!");
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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
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
      if(signal!=0)
      printf("Trading Signal:"+IntegerToString(signal));
      
//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
