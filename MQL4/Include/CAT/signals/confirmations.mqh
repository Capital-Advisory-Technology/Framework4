// Functions used as confirmations when building a model.            |
// Commented above the function is QC for Quality Control &          |
// Function variables with suggested ranges, note that {}            |
// means flexible & [] means fixed (including)                       |

#property copyright "Framework 4"
#property strict

#include <CAT/common/enums.mqh>
#include <CAT/common/utils.mqh>
#include <CAT/signals/entry.mqh>

// #define WDH_PATH "Indicators\\Waddah.ex4"

// #ifdef WDH_PATH
//   #resource "\\" + WDH_PATH
// #endif

//| AMA Baseline check (QC)
//| AMA_period - {24 - 120}  |  AMA_nfast - {2 - 10}  |  AMA_nslow - {30 - 50}
//| AMA_g - [1.0 - 2.0]      |  AMA_dK - [1.0 - 2.0] 
OrderAction AMA_Simple_Baseline(int AMA_period, int AMA_nfast, int AMA_nslow, double AMA_g, double AMA_dK) {
  OrderAction signal = OA_IGNORE;
  double AMA_baseline = iCustom(NULL, 0, "AMA", AMA_period, AMA_nfast, AMA_nslow, AMA_g, AMA_dK, 0, 1);
  if(CheckForLongBaseline(AMA_baseline)) signal = OA_OPEN_LONG;
  if(CheckForShortBaseline(AMA_baseline)) signal = OA_OPEN_SHORT;
  return signal;
}
  
//| EMA Baseline check (QC)
//| EMA_period - {65 - 200}  |  EMA_set_price - [0 - 8]                           
OrderAction EMA_Baseline(double EMA_period, double EMA_set_price) {
  OrderAction signal = OA_IGNORE;
  double EMA_baseline = iCustom(NULL, 0, "EMA", EMA_period, 0.0, 0, EMA_set_price, 0, 1);
  if(CheckForLongBaseline(EMA_baseline)) signal = OA_OPEN_LONG;
  if(CheckForShortBaseline(EMA_baseline)) signal = OA_OPEN_SHORT;
  return signal;
}

//| DEMA Baseline check (QC)
//| cDEMA_period - {60 - 200}     |  cDEMA_enum_price - [ANY enPrice ENUM]  |  cDEMA_Filter = {0 - 8}
//| cDEMA_FilterPeriod - {0 - 8}  |  cDEMA_enum_filter - [0 - 2]                          
OrderAction DEMA_Baseline(double cDEMA_period, int cDEMA_enum_price, double cDEMA_Filter, int cDEMA_FilterPeriod, int cDEMA_enum_filter) {
  OrderAction signal = OA_IGNORE;

  enPrices DEMA_Price = (enPrices)cDEMA_enum_price; 
  enFilterWhat DEMA_FilterOn = (enFilterWhat)cDEMA_enum_filter;

  double DEMA_Baseline = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, cDEMA_period, DEMA_Price, cDEMA_Filter, cDEMA_FilterPeriod, DEMA_FilterOn, 0, 1);
  if(CheckForLongBaseline(DEMA_Baseline)) signal = OA_OPEN_LONG;
  if(CheckForShortBaseline(DEMA_Baseline)) signal = OA_OPEN_SHORT;
  return signal; 
}

//| Trend Intensity 2 Baseline check (QC)
//| NOTE: THIS INDICATOR IS SOPHISTICATED, MUST BE ADAPTED AND OPTIMIZED AFTER CREATING
//| A REASONABLE ENTRY LOGIC - after that ranges for period & prices can be optimised as per entry logic.
OrderAction Trend_intensity2_Confirmation(int len, int TI2_price, ENUM_MA_METHOD ma_method) {
  OrderAction signal = OA_IGNORE;

  enPrices price = (enPrices)TI2_price; // Price to use

  double ti2 = iCustom(NULL,0,"trend-intensity2",len,price,ma_method,80,20,0,1);
  if(ti2 <= -1) signal = OA_OPEN_LONG;
  if(ti2 >= 101) signal = OA_OPEN_SHORT;
  return signal;
}

//| VIDYA Baseline check (QC)  
//| period - {10 - 80}  |  histper - {30 - 100}                                       
OrderAction VIDYA_Baseline(int period, int histper) { 
  OrderAction signal = OA_IGNORE;
  double VIDYA_Baseline = iCustom(NULL,0,"VIDYA",period,histper,0,1);
  if(CheckForLongBaseline(VIDYA_Baseline)) signal = OA_OPEN_LONG;
  if(CheckForShortBaseline(VIDYA_Baseline)) signal = OA_OPEN_SHORT;
  return signal;
}

//| Trend Lord Trend Confirmation (QC)
//| Trend_Lord_len - {5 - 20}  |  Trend_Lord_mode - {ANY MQL MA METHOD}
//| Trend_Lord_price - {ANY MQL APPLIED PRICE METHOD} 
OrderAction Trend_Lord_Confirmation(int Trend_Lord_len, ENUM_MA_METHOD Trend_Lord_mode, ENUM_APPLIED_PRICE Trend_Lord_price) {
  OrderAction signal = OA_IGNORE;

  double TrendLordBuy = iCustom(NULL, 0, "trend-lord",Trend_Lord_len,Trend_Lord_mode,Trend_Lord_price,0,1);
  double TrendLordSell = iCustom(NULL, 0, "trend-lord",Trend_Lord_len,Trend_Lord_mode,Trend_Lord_price,1,1);

  if(CheckForLong(TrendLordBuy, TrendLordSell)) signal = OA_OPEN_LONG;
  if(CheckForShort(TrendLordBuy, TrendLordSell)) signal = OA_OPEN_SHORT;
  return signal;
}

//| Waddah Confirmation (QC)
//| NOTE: THIS INDICATOR IS SOPHISTICATED, MUST BE ADAPTED AND OPTIMIZED AFTER CREATING
//| A REASONABLE ENTRY LOGIC - after that ranges for period & prices can be optimised as per entry logic.
OrderAction Waddah_Confirmation(int cWDH_sensetive, int WDH_deadZone, int WDH_explosionPower, int WDH_trendPower) {
  OrderAction signal = OA_IGNORE;
  string Waddah_path;
  #ifdef WDH_PATH
  Waddah_path = "::" + WDH_PATH;
  #else
  Waddah_path = "Waddah";
  #endif
  
  double WaddahBuy = iCustom(NULL, 0, Waddah_path, cWDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 0, 1);
  double WaddahSell = iCustom(NULL, 0, Waddah_path, cWDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 1, 1);
  double WaddahBaseline = iCustom(NULL, 0, Waddah_path, cWDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower, 2, 1);

  if(WaddahBuy > WaddahBaseline) signal = OA_OPEN_LONG;
  if(WaddahSell > WaddahBaseline) signal = OA_OPEN_SHORT;
  return signal;
}

//| Low-Pass-Filter Baseline (QC)
//| LPF_price - {0 - 6}  |  LPF_order - {1 - 3}  |  LPF_filterPeriod - {14 - 28}
//| LPF_PreSmooth - {1 - 10}  |  LPF_PctFilter - {0.0 - 3.0}
OrderAction Low_Pass_Filter_Baseline(int LPF_price, int LPF_order, int LPF_filterPeriod, int LPF_PreSmooth, double LPF_PctFilter) {
  OrderAction signal = OA_IGNORE;
  double LowPassBaseline = iCustom(NULL, 0, "low-pass-filter", LPF_price,LPF_order,LPF_filterPeriod,LPF_PreSmooth,0,LPF_PctFilter, 0, 1);
  if(CheckForLongBaseline(LowPassBaseline)) signal = OA_OPEN_LONG;
  if(CheckForShortBaseline(LowPassBaseline)) signal = OA_OPEN_SHORT;
  return signal;
}

//| RSI Confirmation (QC) (OA_CONFIRMED)
//| RSI_period - {14 - 28}
OrderAction RSI_Confirmation(int RSI_period) {
  OrderAction signal = OA_IGNORE;
  double RSI_Line = iCustom(NULL, 0, "RSI", RSI_period, 0, 1);
  if(RSI_Line > 30 && RSI_Line < 70) signal = OA_CONFIRMED;
  return signal;
}

//| ATRP Confirmation (QC) (OA_CONFIRMED)
//| RSI_period - {14 - 28}
OrderAction ATRP_Confirmation(int cATR_period, double threshold) {
    OrderAction signal = OA_IGNORE;
    double ATRP_Line = iCustom(NULL, 0, "ATRP", cATR_period, 0, 1);
    if(ATRP_Line > threshold) signal = OA_CONFIRMED;
    return signal;
}


OrderAction STDDEV_Confirmation(int period, double threshold) {
    OrderAction signal = OA_IGNORE;
    double stdDevLine = iStdDev(NULL,0, period, 0, MODE_EMA, PRICE_CLOSE, 1);
    if(stdDevLine > threshold) signal = OA_CONFIRMED;
    return signal;
}