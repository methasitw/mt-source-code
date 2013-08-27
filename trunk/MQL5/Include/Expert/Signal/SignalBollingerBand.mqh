//+------------------------------------------------------------------+
//|                                          SignalBollingerBand.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include <Trade\Trade.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Bollinger Band'                  |
//| Type=SignalAdvanced                                              |
//| Name=Bollinger Band                                         |
//| ShortName=BB                                                     |
//| Class=CSignalBollingerBand                                                  |
//| Page=signal_bb                                                   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalBollingerBand.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Bollinger Band' indicator.                     |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalBollingerBand : public CExpertSignal
  {
protected:
   CiBands           m_bb;            // object-indicator
   CiADX             m_adx;
   CiRSI             m_rsi;
   //--- "weights" of market models (0-100)
   int               m_pattern_0;     
   int               m_adx_period;
   int               m_adx_threshold;
   int               m_rsi_top;
   int               m_rsi_bottom;
   int               m_rsi_period;
   
   int               m_bb_period;
   int               m_bb_shift;
   double            m_bb_dev;
   ENUM_APPLIED_PRICE m_bb_applied;
  
  
public:
                     CSignalBollingerBand(void);
                    ~CSignalBollingerBand(void);
   void              ADX_MA_Period(int value)       {m_adx_period=value;         }
   void              ADXThreshold(int value)     {m_adx_threshold=value;      }
   void              RSI_Top(int value)     {m_rsi_top=value;      }
   void              RSI_Bottom(int value)     {m_rsi_bottom=value;      }
   void              RSI_Period(int value)     {m_rsi_period=value;      }
   void              BB_Period(int value){m_bb_period=value;}
   void              BB_Shift(int value){m_bb_shift=value;}
   void              BB_Applied(ENUM_APPLIED_PRICE value){m_bb_applied=value;}
   void              BB_Deviation(double value){m_bb_dev=value;}
   
   
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)        { m_pattern_0=value;         }
   void              ClosePosition();
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitBB(CIndicators *indicators);
   //--- methods of getting data
   double            ADX_Main(int ind)           {return m_adx.Main(ind);}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBollingerBand::CSignalBollingerBand(void) : m_pattern_0(80)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalBollingerBand::~CSignalBollingerBand(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalBollingerBand::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize AO indicator
   if(!InitBB(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize AO indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalBollingerBand::InitBB(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_bb)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
     
    if(!indicators.Add(GetPointer(m_adx)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
     
    if(!indicators.Add(GetPointer(m_rsi)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_bb.Create(m_symbol.Name(),m_period,m_bb_period,m_bb_shift,m_bb_dev,m_bb_applied))
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
     if(!m_rsi.Create(m_symbol.Name(),m_period,m_rsi_period,PRICE_CLOSE))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
  void CSignalBollingerBand::ClosePosition()
  {
    CPositionInfo position;
    CTrade trade;
    CSymbolInfo symbol;
    symbol.Name(Symbol());
    
    if(position.Select(symbol.Name()))
    {
     int idx   =StartIndex();
     if(m_rsi.Main(idx)>m_rsi_bottom&&m_rsi.Main(idx+1)<m_rsi_bottom)
     {
         if(position.PositionType()==POSITION_TYPE_SELL)
         {
           trade.PositionClose(symbol.Name());
         }
     }
     
     if(m_rsi.Main(idx)<m_rsi_top&&m_rsi.Main(idx+1)>m_rsi_top)
     {
         if(position.PositionType()==POSITION_TYPE_BUY)
         {
           trade.PositionClose(symbol.Name());
         }
     }    
    }
  }
  
  
  
  
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalBollingerBand::LongCondition(void)
  {
  
   //ClosePosition();
   int result=0;
   int idx   =StartIndex();
   double close=Close(idx);
   if(Close(idx)>m_bb.Upper(idx)&&Close(idx+1)<m_bb.Upper(idx+1))
   {
      if(m_adx.Main(idx)> m_adx_threshold)
      result=m_pattern_0;
   }
   
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalBollingerBand::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   if(Close(idx)<m_bb.Lower(idx)&&Close(idx+1)>m_bb.Lower(idx+1))
   {
      if(m_adx.Main(idx)> m_adx_threshold)
      result=m_pattern_0;
      
   }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
