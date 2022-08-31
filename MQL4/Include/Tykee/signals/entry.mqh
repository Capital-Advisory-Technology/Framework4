//+------------------------------------------------------------------+
//|                                                        entry.mqh |
//|                                           Copyright 2022,  Tykee |
//+------------------------------------------------------------------+

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>

//+------------------------------------------------------------------+
//| TE Crossover Entry (TESTED & MODIFIED)                           |
//+------------------------------------------------------------------+
OrderAction TE_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   ENUM_TIMEFRAMES TE_tf = PERIOD_CURRENT;
   int TE_MaPeriod = 36;
   int TE_MaFilterPass = 1;
   int TE_MaShift = 0;
   double TE_Deviation = 0.2;
   enPrices TE_Price = pr_habweighted;

   double TE_Buy = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
   double TE_Sell = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
   double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
   double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

   if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }

//+------------------------------------------------------------------+
//| TE Crossover Entry w/ Macro (TESTED & MODIFIED)                  |
//+------------------------------------------------------------------+
OrderAction TE_Macro_Micro_Cross() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   ENUM_TIMEFRAMES TE_tf = PERIOD_CURRENT;
   int TE_MaPeriod = 36;
   int TE_MaFilterPass = 1;
   int TE_MaShift = 0;
   double TE_Deviation = 0.2;
   enPrices TE_Price = pr_habweighted;

   ENUM_TIMEFRAMES mTE_tf = PERIOD_D1;
   int mTE_MaPeriod = 36;
   int mTE_MaFilterPass = 1;
   int mTE_MaShift = 0;
   double mTE_Deviation = 0.2;
   enPrices mTE_Price = pr_habweighted;


   double TE_Buy = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 1);
   double TE_Sell = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 1);
   double TE_BuyPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 0, 2);
   double TE_SellPrev = iCustom(NULL, 0, "trend-envelope", TE_tf, TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_Price, 1, 2);

   double TE_Macro_Buy = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 1);
   double TE_Macro_Sell = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 1);
   double TE_Macro_BuyPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 0, 2);
   double TE_Macro_SellPrev = iCustom(NULL, mTE_tf, "trend-envelope", mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_Price, 1, 2);

   if(LongCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForLong(TE_Macro_Buy,  TE_Macro_Sell,  TE_Macro_BuyPrev,  TE_Macro_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TE_Buy,  TE_Sell,  TE_BuyPrev,  TE_SellPrev) && CheckForShort(TE_Macro_Buy,  TE_Macro_Sell,  TE_Macro_BuyPrev,  TE_Macro_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }

//+------------------------------------------------------------------+
//|  BDSS Crossover Entry (TESTED & MODIFIED)                        |
//+------------------------------------------------------------------+
OrderAction BDSS_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int SMMA_period = 8;
   int stochastic_period = 5;

   double BDSS_Buy = iCustom(NULL, 0, "BDSS", SMMA_period, stochastic_period, 1, 1);
   double BDSS_Sell = iCustom(NULL, 0, "BDSS", SMMA_period, stochastic_period, 2, 1);
   double BDSS_BuyPrev = iCustom(NULL, 0, "BDSS", SMMA_period, stochastic_period, 1, 2);
   double BDSS_SellPrev = iCustom(NULL, 0, "BDSS", SMMA_period, stochastic_period, 2, 2);

   if(LongCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(BDSS_Buy,  BDSS_Sell,  BDSS_BuyPrev,  BDSS_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;

  }
//+------------------------------------------------------------------+
//| Aroon Crossover Entry (TESTED & MODIFIED)                        |
//+------------------------------------------------------------------+
OrderAction Aroon_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int Aroon_period = 72;

   double Aroon_Buy = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 1);
   double Aroon_Sell = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 1);
   double Aroon_BuyPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 0, 2);
   double Aroon_SellPrev = iCustom(NULL, 0, "Aroon", Aroon_period, false, false, 1, 2);

   if(LongCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(Aroon_Buy,  Aroon_Sell,  Aroon_BuyPrev,  Aroon_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| ABI Crossover Entry (TESTED & MODIFIED)                          |
//+------------------------------------------------------------------+
OrderAction ABI_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   bool useRSI = false; // false uses Stochastic
   double len = 10; // length
   double Signal = 5; // signal period
   double smooth = 5; // smooth period
   enMaTypes MaMethod = ma_sma; // MA type
   enPrices Price = pr_close; // Price

   double ABI_Buy = iCustom(NULL, 0, "ABI", useRSI, len, signal, smooth, MaMethod, Price, 0, 1);
   double ABI_Sell = iCustom(NULL, 0, "ABI", useRSI, len, signal, smooth, MaMethod, Price, 1, 1);
   double ABI_BuyPrev = iCustom(NULL, 0, "ABI", useRSI, len, signal, smooth, MaMethod, Price, 0, 2);
   double ABI_SellPrev = iCustom(NULL, 0, "ABI", useRSI, len, signal, smooth, MaMethod, Price, 1, 2);

   if(LongCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(ABI_Buy,  ABI_Sell,  ABI_BuyPrev,  ABI_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| DEMA Crossover Entry (TESTED & MODIFIED)                         |
//+------------------------------------------------------------------+
OrderAction DEMA_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double DEMA_period = 120;
   enPrices Price = pr_hatbiased2;
   double Filter = 3; 
   int FilterPeriod = 0;
   enFilterWhat FilterOn = flt_prc;

   double DEMA_Buy = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, Price, Filter, FilterPeriod, FilterOn, 3, 1);
   double DEMA_Sell = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, Price, Filter, FilterPeriod, FilterOn, 4, 1);

   if(LongSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_LONG;

   if(ShortSignalEmptyValue(DEMA_Buy,  DEMA_Sell)) signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| SSL Crossover Entry (TESTED & MODIFIED)                          |
//+------------------------------------------------------------------+
OrderAction SSL_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int Lb = 10;

   double SSL_Buy = iCustom(NULL, 0, "SSL_Channel", Lb, 1, 1);
   double SSL_Sell = iCustom(NULL, 0, "SSL_Channel", Lb, 0, 1);
   double SSL_BuyPrev = iCustom(NULL, 0, "SSL_Channel", Lb, 1, 2);
   double SSL_SellPrev = iCustom(NULL, 0, "SSL_Channel", Lb, 0, 2);

   if(LongCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_LONG;

   if(ShortCrossOver(SSL_Buy,  SSL_Sell,  SSL_BuyPrev,  SSL_SellPrev)) signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| linear-reg Crossover Entry (TESTED & MODIFIED)                   |
//+------------------------------------------------------------------+
OrderAction linear_reg_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int period = 120;
   int price = 1; // OHLC representing 0, 1, 2, 3 
   int Shift = 0;

   double lr_Buy = iCustom(NULL, 0, "linear-regression", period, price, Shift, 1, 1);
   double lr_Sell = iCustom(NULL, 0, "linear-regression", period, price, Shift, 2, 1);
   double lr_BuyPrev = iCustom(NULL, 0, "linear-regression", period, price, Shift, 1, 2);
   double lr_SellPrev = iCustom(NULL, 0, "linear-regression", period, price, Shift, 2, 2);

   if(LongCrossOverEmptyValue(lr_Buy, lr_SellPrev)) signal = OA_OPEN_LONG;

   if(ShortCrossOverEmptyValue(lr_Sell,  lr_BuyPrev)) signal = OA_OPEN_SHORT;

   return signal; 
  }
//+------------------------------------------------------------------+
//| trend-flex2 Crossover Entry (TESTED & MODIFIED)                  |
//+------------------------------------------------------------------+
OrderAction trendFlex2_Simple() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int fast_period = 20;
   int slow_period = 50;

   double TrendFlex_Buy = iCustom(NULL, 0, "trend-flex2", fast_period, slow_period, 0, 1);
   double TrendFlex_Sell = iCustom(NULL, 0, "trend-flex2", fast_period, slow_period, 1, 1);
   double TrendFlex_BuyPrev = iCustom(NULL, 0, "trend-flex2", fast_period, slow_period, 0, 2);
   double TrendFlex_SellPrev = iCustom(NULL, 0, "trend-flex2", fast_period, slow_period, 1, 2);

   if(LongCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TrendFlex_Buy,  TrendFlex_Sell,  TrendFlex_BuyPrev,  TrendFlex_SellPrev))
      signal = OA_OPEN_SHORT;

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
