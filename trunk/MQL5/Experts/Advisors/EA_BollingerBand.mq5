//+------------------------------------------------------------------+
//|                                                       EA_AO2.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalBollingerBand.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title                  ="EA_BollingerBand"; // Document name
ulong        Expert_MagicNumber            =27235;    // 
bool         Expert_EveryTick              =false;    // 
//--- inputs for main signal
input double Signal_PriceLevel             =0.0;      // Price level to execute a deal
input double Signal_StopLevel              =50.0;     // Stop Loss level (in points)
input double Signal_TakeLevel              =50.0;     // Take Profit level (in points)
input int    Signal_Expiration             =4;        // Expiration of pending orders (in bars)
input double Signal_BB_Weight              =1.0;      // Awesome Oscillator Weight [0...1.0]
input int    Signal_ADX_MA_Period          =14;       //ADX moving average period
input int    Signal_ADX_Threshold          =50;       //ADX threshold
input int    Signal_RSI_Top                =70;
input int    Signal_RSI_Bottom             =30;
input int    Signal_RSI_Period             =3;

input int    Signal_BB_Period=20;
input int    Signal_BB_Shift=0;
input double Signal_BB_Deviation=2;
input ENUM_APPLIED_PRICE Signal_BB_Applied  =PRICE_CLOSE;

//--- inputs for trailing
input int    Trailing_FixedPips_StopLevel  =30;       // Stop Loss trailing level (in points)
input int    Trailing_FixedPips_ProfitLevel=50;       // Take Profit trailing level (in points)
//--- inputs for money
input double Money_FixLot_Percent          =50.0;     // Percent
input double Money_FixLot_Lots             =0.3;      // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
   signal.ThresholdClose(100);
   signal.ThresholdOpen(60);
   
//--- Creating filter CSignalAO
   CSignalBollingerBand *filter0=new CSignalBollingerBand;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Weight(Signal_BB_Weight);
   filter0.EveryTick(false);
   
   
   filter0.ADXThreshold(Signal_ADX_Threshold);
   filter0.ADX_MA_Period(Signal_ADX_MA_Period);
   filter0.RSI_Top(Signal_RSI_Top);
   filter0.RSI_Bottom(Signal_RSI_Bottom);
   filter0.RSI_Period(Signal_RSI_Period);
   filter0.BB_Period(Signal_BB_Period);
   filter0.BB_Shift(Signal_BB_Shift);
   filter0.BB_Applied(Signal_BB_Applied);
   filter0.BB_Deviation(Signal_BB_Deviation);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
