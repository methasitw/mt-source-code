//+------------------------------------------------------------------+
//|                                                  ExpertSonic_H4.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Indicators\Trend.mqh>

#include <Indicators\TimeSeries.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input double TakeProfit    =200;
input double Buffer=20;
input int MaxOrders=8;
input double Lot=0.1;



int iMAHigh_handle,iMALow_handle,iMAClose_handle;

double iMAHigh;   
double iMALow;   
double iMAClose;   
double iOpenPrice;   

double iHigherMA_0;
double iHigherMA_1;
double iHigherMA_2;

double iLowerMAHigh;
double iLowerMALow;


ENUM_TIMEFRAMES HigherTimeFrame;
ENUM_TIMEFRAMES LowerTimeFrame;



int OnInit()
  {
//---

   if(Period()==PERIOD_H4)
   {
      
      HigherTimeFrame=PERIOD_D1;
      
      LowerTimeFrame=PERIOD_H1;
   }
   
   if(Period()==PERIOD_H1)
   {
      
      HigherTimeFrame=PERIOD_H4;
      
      LowerTimeFrame=PERIOD_M30;
   }
   
   
    if(Period()==PERIOD_M30)
   {
      
      HigherTimeFrame=PERIOD_H1;
      
      LowerTimeFrame=PERIOD_M15;
   }
   
   if(Period()==PERIOD_M15)
   {
      
      HigherTimeFrame=PERIOD_M30;
      
      LowerTimeFrame=PERIOD_M5;
   }
   
   if(Period()==PERIOD_M5)
   {
      
      HigherTimeFrame=PERIOD_M15;
      
      LowerTimeFrame=PERIOD_M1;
   }
   

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

      

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   RefreshRates();
   
   iMAHigh=iMA(Symbol(),Period(),34,0,MODE_EMA,PRICE_HIGH,0);  
   iMALow=iMA(Symbol(),Period(),34,0,MODE_EMA,PRICE_LOW,0);  
   iMAClose=iMA(Symbol(),Period(),34,0,MODE_EMA,PRICE_CLOSE,0);
     
   
   iHigherMA_0=iMA(Symbol(),HigherTimeFrame,34,0,MODE_EMA,PRICE_CLOSE,0);  
   iHigherMA_1=iMA(Symbol(),HigherTimeFrame,34,0,MODE_EMA,PRICE_CLOSE,1);  
   iHigherMA_2=iMA(Symbol(),HigherTimeFrame,34,0,MODE_EMA,PRICE_CLOSE,2);  
   
   iLowerMAHigh=iMA(Symbol(),LowerTimeFrame,34,0,MODE_EMA,PRICE_HIGH,0);
   iLowerMALow=iMA(Symbol(),LowerTimeFrame,34,0,MODE_EMA,PRICE_LOW,0);  
     
   
   
   iOpenPrice=iOpen(Symbol(),Period(),0); 
              
   
   double tp,sl;
   double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
    
    bool hasPosition=false;
    
    int _GetLastError = 0, _OrdersTotal = OrdersTotal();
 
    for ( int i = _OrdersTotal - 1; i >= 0; i -- )
    {
        if ( !OrderSelect(i,SELECT_BY_POS ) )
        {
          Print("OrderSelect( ", i, ", SELECT_BY_POS ) - Error #",
                GetLastError() );
            continue;
        }
        if ( OrderSymbol() == Symbol() ) 
        {
        
          hasPosition=true;
        
         //check to move sl to entry level
         double currentSL=OrderStopLoss();
         double openPrice=OrderOpenPrice(); 
         if(OrderType()==OP_BUY)
         {
          
           //If we have 30bps profit and current sl is lower than entry price
           if(Bid>openPrice+TakeProfit*point&&currentSL<openPrice)
           {
           
             bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
              if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
              else 
               Print("Order modified successfully.");
               
               continue;
             
           }
           
           //If sl>=entry level, move sl to MAHigh
           
           if(currentSL>=openPrice&&currentSL<iMAHigh)
           {
              double newStopLoss=iMAHigh-Buffer*point;
              //do nothing if newSL<=currentSL
              if(newStopLoss<=currentSL)
              continue;
              
              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),0);
              if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
              else 
               Print("Order modified successfully.");
               
               continue;
           }
           
           
         }
         else if(OrderType()==OP_SELL)
         {
             //If we have 30bps profit and current sl is lower than entry price
           if(Ask<openPrice-TakeProfit*point&&currentSL>openPrice)
           {
           
             bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
              if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
              else 
               Print("Order modified successfully.");
               
               continue;
               
           }
           
            //If sl<=entry level, move sl to MALow
           if(currentSL<=openPrice&&currentSL>iMALow)
           {
              double newStopLoss=iMALow+Buffer*point;
              //do nothing if newStopLoss>=currentSL
              if(newStopLoss>=currentSL)
              continue;
              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),0);
              if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
              else 
               Print("Order modified successfully.");
               
               continue;
           }
           
            
         }
         
        }
   }
   //We dont hold positions and total orders<limit for current symbol. check for open.
   if(!hasPosition&&_OrdersTotal<MaxOrders)
   {
   
  
            //candle always use bid price
            if(Bid>iMAHigh+Buffer*point&&Bid<iMAHigh+TakeProfit*point/2&&iOpenPrice<iMAHigh)
            {
               bool lowerTimeFrameCheck=(iHigherMA_0>iHigherMA_1&&iHigherMA_1>iHigherMA_2&&Bid>iLowerMAHigh);
               
               if(Period()==PERIOD_D1||(Period()!=PERIOD_D1&&lowerTimeFrameCheck))
               {
                  
                  sl=(iMAClose-Buffer*point)>(Ask-1000*point)?(iMAClose-Buffer*point):(Ask-1000*point);
                  double slMin=Ask-minstoplevel*point;
                  //check min stoploss
                  if(sl>slMin)
                   sl=slMin;
                  
                  tp=Ask+TakeProfit*point;
                  
                  
                  
                  bool res;
                  res=OrderSend(Symbol(),OP_BUY,Lot,Ask,3,sl,0);
                  if(!res)
                     Print("Error in OrderSend. Error code=",GetLastError());
                  res=OrderSend(Symbol(),OP_BUY,Lot,Ask,3,sl,tp);
                  if(!res)
                     Print("Error in OrderSend. Error code=",GetLastError());
              
               }
               
            }
            
            if(Bid<iMALow-Buffer*point&&Bid>iMALow-TakeProfit*point/2&&iOpenPrice>iMALow)
            {
            
              bool lowerTimeFrameCheck=(iHigherMA_0<iHigherMA_1&&iHigherMA_1<iHigherMA_2&&Bid<iLowerMALow);
              
              if(Period()==PERIOD_D1||(Period()!=PERIOD_D1&&lowerTimeFrameCheck))
              {
                sl=(iMAClose+Buffer*point)<(Bid+1000*point)?(iMAClose+Buffer*point):(Bid+1000*point); 
                double slMin=Bid+minstoplevel*point;
                  //check min stoploss
                  if(sl<slMin)
                   sl=slMin;
                
                tp=Bid-TakeProfit*point;
                bool res;
                res=OrderSend(Symbol(),OP_SELL,Lot,Bid,3,sl,0);
                if(!res)
                  Print("Error in OrderSend. Error code=",GetLastError());
                res=OrderSend(Symbol(),OP_SELL,Lot,Bid,3,sl,tp);
                if(!res)
                 Print("Error in OrderSend. Error code=",GetLastError());
              }
            }
              
   }


      
     
}
//+------------------------------------------------------------------+
