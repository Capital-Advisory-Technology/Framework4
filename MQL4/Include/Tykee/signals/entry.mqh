//+------------------------------------------------------------------+
//|                                                        entry.mqh |
//|                                           Copyright 2022,  Tykee |
//+------------------------------------------------------------------+

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>

// TE Crossover Entry (TESTED & MODIFIED)                           
OrderAction TE_Simple(ENUM_TIMEFRAMES TE_tf, int TE_MaPeriod, int TE_MaFilterPass, int TE_MaShift, double TE_Deviation) 
  {
   OrderAction signal = OA_IGNORE;
   enPrices TE_Price = pr_habweighted;

   double TE_Buy = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
   double TE_Sell = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
   double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
   double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

   if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }

// TE Crossover Entry w/ Macro (TESTED & MODIFIED)                  
OrderAction TE_Macro_Micro_Cross(ENUM_TIMEFRAMES TE_tf, int TE_MaPeriod, int TE_MaFilterPass, int TE_MaShift, double TE_Deviation, ENUM_TIMEFRAMES mTE_tf, int mTE_MaPeriod, int mTE_MaFilterPass, int mTE_MaShift, double mTE_Deviation) 
  {
   OrderAction signal = OA_IGNORE;
   enPrices TE_Price = pr_habweighted;
   enPrices mTE_Price = pr_habweighted;

   double TE_Buy = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
   double TE_Sell = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
   double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
   double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

   double TE_Macro_Buy = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 1);
   double TE_Macro_Sell = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 1);
   double TE_Macro_BuyPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 2);
   double TE_Macro_SellPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 2);

   if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForLong(TE_Macro_Buy,  TE_Macro_Sell,  TE_Macro_BuyPrev,  TE_Macro_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForShort(TE_Macro_Buy,  TE_Macro_Sell,  TE_Macro_BuyPrev,  TE_Macro_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }

//  BDSS Crossover Entry (TESTED & MODIFIED)                        
OrderAction BDSS_Simple(int BDSS_SMMA_period, int BDSS_stochastic_period) 
  {
   OrderAction signal = OA_IGNORE;

   double BDSS_Buy = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 1, 1);
   double BDSS_Sell = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 2, 1);
   double BDSS_BuyPrev = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 1, 2);
   double BDSS_SellPrev = iCustom(NULL, 0, "BDSS", BDSS_SMMA_period, BDSS_stochastic_period, 2, 2);

   if(LongCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }

// Aroon Crossover Entry (TESTED & MODIFIED)                        
OrderAction Aroon_Simple(int Aroon_period) 
  {
   OrderAction signal = OA_IGNORE;

   double Aroon_Buy = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 1);
   double Aroon_Sell = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 1);
   double Aroon_BuyPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 2);
   double Aroon_SellPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 2);

   if(LongCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }
// ABI Crossover Entry (TESTED & MODIFIED)                          
OrderAction ABI_Simple(bool ABI_useRSI, double ABI_len, double ABI_Signal, double ABI_smooth) 
  {
   OrderAction signal = OA_IGNORE;
   enMaTypes ABI_MaMethod = ma_sma; // MA type
   enPrices ABI_Price = pr_close; // Price

   double ABI_Buy = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, ABI_Signal, ABI_smooth, ABI_MaMethod, ABI_Price, 0, 1);
   double ABI_Sell = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, ABI_Signal, ABI_smooth, ABI_MaMethod, ABI_Price, 1, 1);
   double ABI_BuyPrev = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, ABI_Signal, ABI_smooth, ABI_MaMethod, ABI_Price, 0, 2);
   double ABI_SellPrev = iCustom(NULL, 0, "ABI", ABI_useRSI, ABI_len, ABI_Signal, ABI_smooth, ABI_MaMethod, ABI_Price, 1, 2);

   if(LongCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }
// DEMA Crossover Entry (TESTED & MODIFIED)                         
OrderAction DEMA_Simple(double DEMA_period, double DEMA_Filter, int DEMA_FilterPeriod) 
  {
   OrderAction signal = OA_IGNORE;
   enPrices DEMA_Price = pr_hatbiased2;
   enFilterWhat DEMA_FilterOn = flt_prc;

   double DEMA_Buy = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_Filter, DEMA_FilterPeriod, DEMA_FilterOn, 3, 1);
   double DEMA_Sell = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_Filter, DEMA_FilterPeriod, DEMA_FilterOn, 4, 1);

   if(LongSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_LONG;
   if(ShortSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_SHORT;

   return signal;
  }
// SSL Crossover Entry (TESTED & MODIFIED)                          
OrderAction SSL_Simple(int SSL_Lb) 
  {
   OrderAction signal = OA_IGNORE;

   double SSL_Buy = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 1, 1);
   double SSL_Sell = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 0, 1);
   double SSL_BuyPrev = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 1, 2);
   double SSL_SellPrev = iCustom(NULL, 0, "SSL_Channel", SSL_Lb, 0, 2);

   if(LongCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }

// linear-reg Crossover Entry (TESTED & MODIFIED)                   
OrderAction linear_reg_Simple(int lr_period, int lr_price, int lr_Shift) 
  {
   OrderAction signal = OA_IGNORE;

   double lr_Buy = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, lr_Shift, 1, 1);
   double lr_Sell = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, lr_Shift, 2, 1);
   double lr_BuyPrev = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, lr_Shift, 1, 2);
   double lr_SellPrev = iCustom(NULL, 0, "linear-regression", lr_period, lr_price, lr_Shift, 2, 2);

   if(LongCrossOverEmptyValue(lr_Buy, lr_SellPrev)) signal = OA_OPEN_LONG;
   if(ShortCrossOverEmptyValue(lr_Sell,  lr_BuyPrev)) signal = OA_OPEN_SHORT;

   return signal; 
  }

// trend-flex2 Crossover Entry (TESTED & MODIFIED)                  
OrderAction trendFlex2_Simple(int tf2_fast_period, int tf2_slow_period) 
  {
   OrderAction signal = OA_IGNORE;

   double TrendFlex_Buy = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 0, 1);
   double TrendFlex_Sell = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 1, 1);
   double TrendFlex_BuyPrev = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 0, 2);
   double TrendFlex_SellPrev = iCustom(NULL, 0, "trend-flex2", tf2_fast_period, tf2_slow_period, 1, 2);

   if(LongCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev)) signal = OA_OPEN_LONG;

   if(ShortCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }

//+------------------------------------------------------------------+
enum enPrices
  {
   pr_close,       // Close
   pr_open,        // Open
   pr_high,        // High
   pr_low,         // Low
   pr_median,      // Median
   pr_typical,     // Typical
   pr_weighted,    // Weighted
   pr_average,     // Average (high+low+open+close)/4
   pr_medianb,     // Average median body (open+close)/2
   pr_tbiased,     // Trend biased price
   pr_tbiased2,    // Trend biased (extreme) price
   pr_haclose,     // Heiken ashi close
   pr_haopen,      // Heiken ashi open
   pr_hahigh,      // Heiken ashi high
   pr_halow,       // Heiken ashi low
   pr_hamedian,    // Heiken ashi median
   pr_hatypical,   // Heiken ashi typical
   pr_haweighted,  // Heiken ashi weighted
   pr_haaverage,   // Heiken ashi average
   pr_hamedianb,   // Heiken ashi median body
   pr_hatbiased,   // Heiken ashi trend biased price
   pr_hatbiased2,  // Heiken ashi trend biased (extreme) price
   pr_habclose,    // Heiken ashi (better formula) close
   pr_habopen,     // Heiken ashi (better formula) open
   pr_habhigh,     // Heiken ashi (better formula) high
   pr_hablow,      // Heiken ashi (better formula) low
   pr_habmedian,   // Heiken ashi (better formula) median
   pr_habtypical,  // Heiken ashi (better formula) typical
   pr_habweighted, // Heiken ashi (better formula) weighted
   pr_habaverage,  // Heiken ashi (better formula) average
   pr_habmedianb,  // Heiken ashi (better formula) median body
   pr_habtbiased,  // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
  };

enum enMaTypes
  {
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
  };
enum enFilterWhat
 {
   flt_prc,   // Filter the price
   flt_val,   // Filter the Dema value
   flt_both  // Filter both
 };


//+------------------------------------------------------------------+
