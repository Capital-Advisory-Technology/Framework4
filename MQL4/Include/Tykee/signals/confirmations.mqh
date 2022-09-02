//+------------------------------------------------------------------+
//|                                                confirmations.mqh |
//|                                           Copyright 2022,  Tykee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>
#include <Tykee/signals/entry.mqh>
#include <Tykee/main/backtest.mqh>

// AMA Baseline check (TESTED & MODIFIED)                           
OrderAction AMA_Simple_Baseline(int AMA_period, int AMA_nfast, int AMA_nslow, double AMA_g, double AMA_dK) 
  {
   addToConfirmationFunctionList("AMA_Simple_Baseline");
   OrderAction signal = OA_IGNORE;
   double AMA_baseline = iCustom(NULL, 0, "AMA", AMA_period, AMA_nfast, AMA_nslow, AMA_g, AMA_dK, 0, 1);
   if(CheckForLongBaseline(AMA_baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(AMA_baseline)) signal = OA_OPEN_SHORT;
   return signal;
  }
// EMA Baseline check (TESTED & MODIFIED)                           
OrderAction EMA_Baseline(double EMA_period, double EMA_set_price) 
  {
   addToConfirmationFunctionList("EMA_Baseline");

   OrderAction signal = OA_IGNORE;
   double EMA_baseline = iCustom(NULL, 0, "EMA", EMA_period, 0.0, 0, EMA_set_price, 0, 1);
   if(CheckForLongBaseline(EMA_baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(EMA_baseline)) signal = OA_OPEN_SHORT;

   return signal;
  }
// DEMA Baseline check (TESTED & MODIFIED)                          
OrderAction DEMA_Baseline(double DEMA_period, double DEMA_Filter, int DEMA_FilterPeriod, int DEMA_enum_price, int DEMA_enum_filter) 
  { 
    addToConfirmationFunctionList("DEMA_Baseline");
   OrderAction signal = OA_IGNORE;
   enPrices DEMA_Price = DEMA_enum_price; 
   enFilterWhat DEMA_FilterOn = DEMA_enum_filter;
   double DEMA_Baseline = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_Filter, DEMA_FilterPeriod, DEMA_FilterOn, 0, 1);

   if(CheckForLongBaseline(DEMA_Baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(DEMA_Baseline)) signal = OA_OPEN_SHORT;

   return signal; 
  }

// Trend Intensity 2 Baseline value check (TESTED & MODIFIED)
OrderAction Trend_intensity2_Simple(int len, int TI2_price, ENUM_MA_METHOD ma_method, double high_level, double low_level) {
  addToConfirmationFunctionList("Trend_intensity2_Confirmation");
   OrderAction signal = OA_IGNORE;
   enPrices price = TI2_price; // Price to use
   double ti2 = iCustom(NULL,0,"trend-intensity2",len,price,ma_method,high_level,low_level,0,1);
   if(ti2 <= -1) signal = OA_OPEN_LONG;
   if(ti2 >= 101) signal = OA_OPEN_SHORT;
   return signal;
}

// VIDYA Baseline check (TESTED & MODIFIED)                                         
OrderAction VIDYA_Baseline(int period, int histper) { 
  addToConfirmationFunctionList("VIDYA_Baseline");
   OrderAction signal = OA_IGNORE;
   double VIDYA_Baseline = iCustom(NULL,0,"VIDYA",period,histper,0,1);
   if(CheckForLongBaseline(VIDYA_Baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(VIDYA_Baseline)) signal = OA_OPEN_SHORT;
   return signal;
}

// Trend Lord Trend Confirmation (TESTED & MODIFIED) 
OrderAction Trend_Lord_Confirmation(int Trend_Lord_len, ENUM_MA_METHOD Trend_Lord_mode, ENUM_APPLIED_PRICE Trend_Lord_price) 
  {
  addToConfirmationFunctionList("Trend_Lord_Confirmation");
  OrderAction signal = OA_IGNORE;
  double TrendLordBuy = iCustom(NULL, 0, "trend-lord",Trend_Lord_len,Trend_Lord_mode,Trend_Lord_price,0,1);
  double TrendLordSell = iCustom(NULL, 0, "trend-lord",Trend_Lord_len,Trend_Lord_mode,Trend_Lord_price,1,1);

  if(CheckForLong(TrendLordBuy, TrendLordSell)) signal = OA_OPEN_LONG;
  if(CheckForShort(TrendLordBuy, TrendLordSell)) signal = OA_OPEN_SHORT;

  return signal;
  }
// Waddah Confirmation (TESTED & MODIFIED)
OrderAction Waddah_Confirmation(int WDH_sensetive, int WDH_deadZone, int WDH_explosionPower, int WDH_trendPower)
  {
    addToConfirmationFunctionList("Waddah_Confirmation");
    OrderAction signal = OA_IGNORE;
    double WaddahBuy = iCustom(NULL, 0, "Waddah", WDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 0, 1);
    double WaddahSell = iCustom(NULL, 0, "Waddah", WDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 1, 1);
    double WaddahBaseline = iCustom(NULL, 0, "Waddah", WDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 2, 1);
    
    if(WaddahBuy > WaddahBaseline) signal = OA_OPEN_LONG;
    if(WaddahSell > WaddahBaseline) signal = OA_OPEN_SHORT;

    return signal;
  }
// Low-Pass-Filter Baseline (TESTED & MODIFIED)
OrderAction Low_Pass_Filter_Baseline(int LPF_price, int LPF_order, int LPF_filterPeriod, int LPF_PreSmooth, int LPF_PreSmoothMode, double LPF_PctFilter)
  {
    addToConfirmationFunctionList("Low_Pass_Filter_Baseline");
    OrderAction signal = OA_IGNORE;
    double LowPassBaseline = iCustom(NULL, 0, "low-pass-filter", LPF_price,LPF_order,LPF_filterPeriod,LPF_PreSmooth,LPF_PreSmoothMode,LPF_PctFilter, 0, 1);
    if(CheckForLongBaseline(LowPassBaseline)) signal = OA_OPEN_LONG;
    if(CheckForShortBaseline(LowPassBaseline)) signal = OA_OPEN_SHORT;
    return signal;
  }
// RSI Confirmation (70 & 30 lvl's) (TESTED & MODIFIED) (OA_CONFIRMED)
OrderAction RSI_Confirmation(int RSI_period)
  {
    addToConfirmationFunctionList("RSI_Confirmation");
    OrderAction signal = OA_IGNORE;
    double RSI_Line = iCustom(NULL, 0, "RSI", RSI_period, 0, 1);
    if(RSI_Line > 30 && RSI_Line < 70) signal = OA_CONFIRMED;
    return signal;
  }