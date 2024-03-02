// Functions used for entry when building a model.
// Commented above the function is QC for Quality Control &
// Function variables with suggested ranges, note that {}     
// means flexible & [] means fixed (including)
#property copyright "Framework 4"
#property strict

#include <CAT/common/enums.mqh>
#include <CAT/common/utils.mqh>

// #define DEMA_PATH "Indicators\\DEMA.ex4"

// #ifdef DEMA_PATH
//   #resource "\\" + DEMA_PATH
// #endif

//| TE Crossover Entry (QC)          
//| TE_MaPeriod - {20 - 250}  |  TE_MaFilterPass - [1 - 98] 
//| TE_MaShift - {0 or 1}     |  TE_Deviation - {0.2 - 1.0}  |  TE_enum_price - [ANY enPrices ENUM]
OrderAction TE_Simple(int TE_MaPeriod, int TE_MaFilterPass, int TE_MaShift, double TE_Deviation, int TE_enum_price) {
  OrderAction signal = OA_IGNORE;
  enPrices TE_Price = (enPrices)TE_enum_price;

  double TE_Buy = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
  double TE_Sell = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
  double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
  double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

  if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| TE Crossover Entry w/ Macro (QC)      
//| TE_MaPeriod - {20 - 250}  |  TE_MaFilterPass - [1 - 98] 
//| TE_MaShift - {0 or 1}     |  TE_Deviation - {0.2 - 1.0}  |  TE_enum_price - [ANY enPrices ENUM]
//| mTE_tf - [4H - W ENUM]    |  mTE_MaPeriod - {20 - 250}   |  mTE_MaFilterPass - [1 - 98] 
//| mTE_MaShift - {0 or 1}    |  mTE_Deviation - {0.2 - 1.0} |  mTE_enum_price - [ANY enPrices ENUM]                
OrderAction TE_Macro_Micro_Cross(int TE_MaPeriod, int TE_MaFilterPass, int TE_MaShift, double TE_Deviation, int TE_enum_price, ENUM_TIMEFRAMES mTE_tf, int mTE_MaPeriod, int mTE_MaFilterPass, int mTE_MaShift, double mTE_Deviation, int mTE_enum_price) {
  OrderAction signal = OA_IGNORE;
  enPrices TE_Price = (enPrices)TE_enum_price;
  enPrices mTE_Price = (enPrices)mTE_enum_price;

  double TE_Buy = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
  double TE_Sell = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
  double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
  double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", PERIOD_CURRENT, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

  double TE_Macro_Buy = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 1);
  double TE_Macro_Sell = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 1);
  double TE_Macro_BuyPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 2);
  double TE_Macro_SellPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 2);

  if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForLong(TE_Macro_Buy,  TE_Macro_Sell)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForShort(TE_Macro_Buy,  TE_Macro_Sell)) signal = OA_OPEN_SHORT;
  return signal;
}

//| BDSS Crossover Entry (QC)
//| BDSS_SMMA_period - {10 - 120}  |  BDSS_stochastic_period - {5 - 50}                         
OrderAction BDSS_Simple(int BDSS_SMMA_period, int BDSS_stochastic_period) {
  OrderAction signal = OA_IGNORE;

  double BDSS_Buy = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 1, 1);
  double BDSS_Sell = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 2, 1);
  double BDSS_BuyPrev = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 1, 2);
  double BDSS_SellPrev = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 2, 2);

  if(LongCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| Aroon Crossover Entry (QC) 
//| Aroon_period - {25 - 80}                        
OrderAction Aroon_Simple(int Aroon_period) {
  OrderAction signal = OA_IGNORE;

  double Aroon_Buy = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 1);
  double Aroon_Sell = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 1);
  double Aroon_BuyPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 2);
  double Aroon_SellPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 2);

  if(LongCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| ABI Crossover Entry (QC)
//| ABI_useRSI - [bool]   |  ABI_len - {10 - 100}  |  ABI_smooth - {5 - 50}       
//| ABI_enum_ma - [ANY enMaTypes ENUM]  |  ABI_enum_price - [ANY enPrices ENUM]                         
OrderAction ABI_Simple(bool ABI_useRSI, double ABI_len, double ABI_smooth, int ABI_enum_ma, int ABI_enum_price) {
  OrderAction signal = OA_IGNORE;
  enMaTypes ABI_MaMethod = (enMaTypes)ABI_enum_ma; // MA type
  enPrices ABI_Price = (enPrices)ABI_enum_price; // Price

  double ABI_Buy = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, 5, ABI_smooth, ABI_MaMethod, ABI_Price, 0, 1);
  double ABI_Sell = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, 5, ABI_smooth, ABI_MaMethod, ABI_Price, 1, 1);
  double ABI_BuyPrev = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, 5, ABI_smooth, ABI_MaMethod, ABI_Price, 0, 2);
  double ABI_SellPrev = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, 5, ABI_smooth, ABI_MaMethod, ABI_Price, 1, 2);

  if(LongCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| DEMA Crossover Entry (QC) 
//| DEMA_period - {20 - 120}
//| DEMA_filter = [0 - 20]  | DEMA_filter_period - {0 - 8}
//| DEMA_enum_filter - [0 - 2]  |  DEMA_enum_price - [0-32]
OrderAction DEMA_Simple(double DEMA_period, int DEMA_enum_price, double DEMA_filter, int DEMA_filter_period, int DEMA_enum_filter) {
  OrderAction signal = OA_IGNORE;
  enPrices DEMA_Price = (enPrices)DEMA_enum_price;
  enFilterWhat DEMA_FilterOn = (enFilterWhat)DEMA_enum_filter;
  string DEMA_path;
  #ifdef DEMA_PATH // if DEMA_PATH is defined, use it
  DEMA_path = "::" + DEMA_PATH;
  #else
  DEMA_path = "DEMA";
  #endif
  double DEMA_Buy = iCustom(NULL, 0, DEMA_path, PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_filter, DEMA_filter_period, DEMA_FilterOn, 3, 1);
  double DEMA_Sell = iCustom(NULL, 0, DEMA_path, PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_filter, DEMA_filter_period, DEMA_FilterOn, 4, 1);
  
  if(LongSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_LONG;
  if(ShortSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_SHORT;
  return signal;
}

//| SSL Crossover Entry (QC)
//| SSL_Lb - {10 - 70}                          
OrderAction SSL_Simple(int SSL_Lb) {
  OrderAction signal = OA_IGNORE;

  double SSL_Buy = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 1, 1);
  double SSL_Sell = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 0, 1);
  double SSL_BuyPrev = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 1, 2);
  double SSL_SellPrev = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 0, 2);

  if(LongCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| linear-reg Crossover Entry (QC) 
//| lr_period - {35 - 145}  |  lr_price [0 - 6]                 
OrderAction linear_reg_Simple(int lr_period, int lr_price) {
  OrderAction signal = OA_IGNORE;

  double lr_Buy = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, 0, 1, 1);
  double lr_Sell = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, 0, 2, 1);
  double lr_BuyPrev = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, 0, 1, 2);
  double lr_SellPrev = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, 0, 2, 2);

  if(LongCrossOverEmptyValue(lr_Buy, lr_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOverEmptyValue(lr_Sell,  lr_BuyPrev)) signal = OA_OPEN_SHORT;
  return signal; 
}

//| trend-flex2 Crossover Entry (QC)
//| tf2_fast_period - {20 - 45}  |  tf2_slow_period - {50 - 70}
OrderAction trendFlex2_Simple(int tf2_fast_period, int tf2_slow_period) {
  OrderAction signal = OA_IGNORE;

  double TrendFlex_Buy = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 0, 1);
  double TrendFlex_Sell = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 1, 1);
  double TrendFlex_BuyPrev = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 0, 2);
  double TrendFlex_SellPrev = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 1, 2);

  if(LongCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| Reflex Crossover Entry (QC)
//| Reflex_Period - {50 - 100} 
OrderAction Reflex_Simple(int Reflex_Period) {
  OrderAction signal = OA_IGNORE;

  double reflex_Buy = iCustom(NULL, 0, "Reflex", Reflex_Period, 0, 1);
  double reflex_Sell = iCustom(NULL, 0, "Reflex", Reflex_Period, 1, 1);
  double reflex_BuyPrev = iCustom(NULL, 0, "Reflex", Reflex_Period, 0, 2);
  double reflex_SellPrev = iCustom(NULL, 0, "Reflex", Reflex_Period, 1, 2);

  if(reflex_Sell == EMPTY_VALUE && reflex_SellPrev != EMPTY_VALUE) signal = OA_OPEN_LONG;
  if(reflex_Sell != EMPTY_VALUE && reflex_SellPrev == EMPTY_VALUE) signal = OA_OPEN_SHORT;
  return signal;
}

//| mega-trend Crossover Entry (QC)
//| megatrend_period - {20 - 150}    |  megatrend_method - [0 - 3] 
//| megatrend_price - [0 - 6]        |
OrderAction MegaTrend_Simple(int megatrend_period, int megatrend_method, int megatrend_price)  {
  OrderAction signal = OA_IGNORE;

  double megatrend_Buy = iCustom(NULL, 0, "mega-trend", megatrend_period, megatrend_method, megatrend_price, 0, 1);
  double megatrend_Sell = iCustom(NULL, 0, "mega-trend", megatrend_period, megatrend_method, megatrend_price, 1, 1);
  double megatrend_BuyPrev = iCustom(NULL, 0, "mega-trend", megatrend_period, megatrend_method, megatrend_price, 0, 2);
  double megatrend_SellPrev = iCustom(NULL, 0, "mega-trend", megatrend_period, megatrend_method, megatrend_price, 1, 2);

  if(LongCrossOverEmptyValue(megatrend_Buy, megatrend_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOverEmptyValue(megatrend_Sell, megatrend_BuyPrev)) signal = OA_OPEN_SHORT;
  return signal;
}

//| ZL MACD Crossover Entry (QC)
//| fast_ema - {12 - 24}   |  slow_ema - {25 - 40}
//| signal_ema - {6 - 20}  |
OrderAction zl_macd_Simple(int fast_ema, int slow_ema, int signal_ema) {
  OrderAction signal = OA_IGNORE;

  double zl_Buy = iCustom(NULL,0,"zl_macd",fast_ema,slow_ema,signal_ema,0,1);
  double zl_Sell = iCustom(NULL,0,"zl_macd",fast_ema,slow_ema,signal_ema,1,1);
  double zl_BuyPrev = iCustom(NULL,0,"zl_macd",fast_ema,slow_ema,signal_ema,0,2);
  double zl_SellPrev = iCustom(NULL,0,"zl_macd",fast_ema,slow_ema,signal_ema,1,2);

  if(LongCrossOver(zl_Buy, zl_Sell, zl_BuyPrev, zl_SellPrev)) signal = OA_OPEN_LONG;
  if(ShortCrossOver(zl_Buy, zl_Sell, zl_BuyPrev, zl_SellPrev)) signal = OA_OPEN_SHORT;
  return signal;
}
  
// Custom ENUMS 0-32
enum enPrices {
  pr_close,       // Close 0
  pr_open,        // Open 1
  pr_high,        // High 2
  pr_low,         // Low 3
  pr_median,      // Median 4
  pr_typical,     // Typical 5
  pr_weighted,    // Weighted 6
  pr_average,     // Average (high+low+open+close)/4 7
  pr_medianb,     // Average median body (open+close)/2 8
  pr_tbiased,     // Trend biased price 9
  pr_tbiased2,    // Trend biased (extreme) price 10
  pr_haclose,     // Heiken ashi close 11
  pr_haopen,      // Heiken ashi open 12
  pr_hahigh,      // Heiken ashi high 13
  pr_halow,       // Heiken ashi low 14 
  pr_hamedian,    // Heiken ashi median 15
  pr_hatypical,   // Heiken ashi typical 16
  pr_haweighted,  // Heiken ashi weighted 17
  pr_haaverage,   // Heiken ashi average 18
  pr_hamedianb,   // Heiken ashi median body 19
  pr_hatbiased,   // Heiken ashi trend biased price 20
  pr_hatbiased2,  // Heiken ashi trend biased (extreme) price 21
  pr_habclose,    // Heiken ashi (better formula) close 22
  pr_habopen,     // Heiken ashi (better formula) open 23
  pr_habhigh,     // Heiken ashi (better formula) high 24
  pr_hablow,      // Heiken ashi (better formula) low 25
  pr_habmedian,   // Heiken ashi (better formula) median 26
  pr_habtypical,  // Heiken ashi (better formula) typical 27
  pr_habweighted, // Heiken ashi (better formula) weighted 28
  pr_habaverage,  // Heiken ashi (better formula) average 29
  pr_habmedianb,  // Heiken ashi (better formula) median body 30
  pr_habtbiased,  // Heiken ashi (better formula) trend biased price 31
  pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price 32
};

enum enMaTypes {
  ma_sma,     // Simple moving average
  ma_ema,     // Exponential moving average
  ma_smma,    // Smoothed MA
  ma_lwma,    // Linear weighted MA
  ma_tema    // Triple exponential moving average - TEMA
};

enum enFilterWhat {
  flt_prc,   // Filter the price
  flt_val,   // Filter the Dema value
  flt_both  // Filter both
};