//+------------------------------------------------------------------+
//|                                                   SignalMACD.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include <Trade\Trade.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of oscillator 'MACD'                               |
//| Type=SignalAdvanced                                              |
//| Name=MACD                                                        |
//| ShortName=MACD                                                   |
//| Class=CSignalMACD                                                |
//| Page=signal_macd                                                 |
//| Parameter=PeriodFast,int,12,Period of fast EMA                   |
//| Parameter=PeriodSlow,int,24,Period of slow EMA                   |
//| Parameter=PeriodSignal,int,9,Period of averaging of difference   |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalMACD.                                               |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Moving Average Convergence/Divergence' oscillator. |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalMACD : public CExpertSignal
  {
protected:
   CiMACD            m_MACD;           // object-oscillator
   CiADX             m_adx;
   CiMA              m_ma;
   
   //--- adjusted parameters
   int               m_period_fast;    // the "period of fast EMA" parameter of the oscillator
   int               m_period_slow;    // the "period of slow EMA" parameter of the oscillator
   int               m_period_signal;  // the "period of averaging of difference" parameter of the oscillator
   ENUM_APPLIED_PRICE m_applied;     
   
   
   int                m_ma_period;
   ENUM_MA_METHOD     m_ma_method;
   ENUM_APPLIED_PRICE m_ma_applied;
   
     // the "price series" parameter of the oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"
   int               m_pattern_2;      // model 2 "crossing of main and signal line"
   int               m_pattern_3;      // model 3 "crossing of main line an the zero level"
   
   //--- variables
   int               m_adx_period;
   int               m_adx_threshold;
public:
void              ClosePosition();
                     CSignalMACD(void);
                    ~CSignalMACD(void);
   void              ADX_MA_Period(int value)       {m_adx_period=value;         }
   void              ADXThreshold(int value)     {m_adx_threshold=value;      }
     
   //--- methods of setting adjustable parameters
   void              PeriodFast(int value)             { m_period_fast=value;           }
   void              PeriodSlow(int value)             { m_period_slow=value;           }
   void              PeriodSignal(int value)           { m_period_signal=value;         }
   
   void              Applied(ENUM_APPLIED_PRICE value) { m_applied=value;               }
   
   void              MA_Applied(ENUM_APPLIED_PRICE value) { m_ma_applied=value;          }
   void              MA_Period(int value) { m_ma_period=value;          }
   void              MA_Method(ENUM_MA_METHOD value) {m_ma_method =value;}
   
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0=value;             }
   void              Pattern_1(int value)              { m_pattern_1=value;             }
   void              Pattern_2(int value)              { m_pattern_2=value;             }
   void              Pattern_3(int value)              { m_pattern_3=value;             }
   
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitMACD(CIndicators *indicators);
   //--- methods of getting data
   double            Main(int ind)                     { return(m_MACD.Main(ind));      }
   double            Signal(int ind)                   { return(m_MACD.Signal(ind));    }
   double            DiffMain(int ind)                 { return(Main(ind)-Main(ind+1)); }
   int               StateMain(int ind);
   double            State(int ind) { return(Main(ind)-Signal(ind)); }
   bool              ExtState(int ind);
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
   double            ADX_Main(int ind)           {return m_adx.Main(ind);}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalMACD::CSignalMACD(void) : m_period_fast(12),
                                 m_period_slow(24),
                                 m_period_signal(9),
                                 m_applied(PRICE_CLOSE),
                                 m_pattern_0(10),
                                 m_pattern_1(0),
                                 m_pattern_2(80),
                                 m_pattern_3(80)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE+USE_SERIES_OPEN;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalMACD::~CSignalMACD(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalMACD::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_period_fast>=m_period_slow)
     {
      printf(__FUNCTION__+": slow period must be greater than fast period");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalMACD::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitMACD(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MACD oscillators.                                     |
//+------------------------------------------------------------------+
bool CSignalMACD::InitMACD(CIndicators *indicators)
  {
//--- add object to collection
   if(!indicators.Add(GetPointer(m_MACD)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
    if(!indicators.Add(GetPointer(m_adx)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
     
        if(!indicators.Add(GetPointer(m_ma)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_MACD.Create(m_symbol.Name(),m_period,m_period_fast,m_period_slow,m_period_signal,m_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
      //--- initialize object
   if(!m_adx.Create(m_symbol.Name(),m_period,m_adx_period))
   
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
      
      if(!m_ma.Create(m_symbol.Name(),m_period,12,1,MODE_EMA,PRICE_CLOSE))
     {
      printf(__FUNCTION__+": error initializing MA object");
      return(false);
     }
     
     
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMACD::LongCondition(void)
  {
   //ClosePosition();
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)>0.0)
     {
      //--- the main line is directed upwards, and it confirms the possibility of price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)<0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)>0.0 && State(idx+1)<0.0&&ADX_Main(idx)>m_adx_threshold)
         {
            //if(Close(idx)>Open(idx)&&Close(idx)>m_ma.Main(idx))
            if(Close(idx)>Open(idx))
            result=m_pattern_2;      // signal number 2
         }
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)>0.0 && Main(idx+1)<0.0&&ADX_Main(idx)>m_adx_threshold)
      {
         
         printf("Current adx:"+DoubleToString(ADX_Main(idx)));
         if(Close(idx)>Open(idx)&&Close(idx)>m_ma.Main(idx))
         
         result=m_pattern_3;      // signal number 3
      }
      //--- if the models 4 or 5 are used and the main line turned upwards below the zero level, look for divergences
      
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMACD::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)<0.0)
     {
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)>0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)<0.0 && State(idx+1)>0.0&&ADX_Main(idx)>m_adx_threshold)
      {
         //if(Close(idx)<Open(idx)&&Close(idx)<m_ma.Main(idx))
         if(Close(idx)<Open(idx))
         result=m_pattern_2;      // signal number 2
      }
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)<0.0 && Main(idx+1)>0.0&&ADX_Main(idx)>m_adx_threshold)
      {
         if(Close(idx)<Open(idx)&&Close(idx)<m_ma.Main(idx))
         result=m_pattern_3;      // signal number 3
         
      }
      //--- if the models 4 or 5 are used and the main line turned downwards above the zero level, look for divergences
      
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
