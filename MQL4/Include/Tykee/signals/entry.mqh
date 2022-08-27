//+------------------------------------------------------------------+
//|                                                        entry.mqh |
//|                                                            Tykee |
//+------------------------------------------------------------------+

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>

//+------------------------------------------------------------------+
//| Trend Envelope (TE) Crossover Entry                              |
//+------------------------------------------------------------------+
OrderAction TE_Simple() // Fully-tested
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double TE_Buy = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,0,1);
   double TE_Sell = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,1,1);
   double TE_BuyPrev = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,0,2);
   double TE_SellPrev = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,1,2);

   if(LongCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }

//+------------------------------------------------------------------+
//| Trend Envelope (TE) Crossover Entry w/ Macro                     |
//+------------------------------------------------------------------+
OrderAction TE_Macro_Micro_Cross() // Fully-tested
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double TE_Buy = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,0,1);
   double TE_Sell = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,1,1);
   double TE_BuyPrev = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,0,2);
   double TE_SellPrev = iCustom(NULL,PERIOD_H1,"trend-envelope",PERIOD_H1,36,1,0,0.2,pr_habweighted,1,2);

   double TE_Macro_Buy = iCustom(NULL,PERIOD_D1,"trend-envelope",PERIOD_D1,36,1,0,0.2,pr_habweighted,0,1);
   double TE_Macro_Sell = iCustom(NULL,PERIOD_D1,"trend-envelope",PERIOD_D1,36,1,0,0.2,pr_habweighted,1,1);
   double TE_Macro_BuyPrev = iCustom(NULL,PERIOD_D1,"trend-envelope",PERIOD_D1,36,1,0,0.2,pr_habweighted,0,2);
   double TE_Macro_SellPrev = iCustom(NULL,PERIOD_D1,"trend-envelope",PERIOD_D1,36,1,0,0.2,pr_habweighted,1,2);

   if(LongCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev) && CheckForLong(TE_Macro_Buy, TE_Macro_Sell, TE_Macro_BuyPrev, TE_Macro_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev) && CheckForShort(TE_Macro_Buy, TE_Macro_Sell, TE_Macro_BuyPrev, TE_Macro_SellPrev))
      signal = OA_OPEN_SHORT;
      
      return signal;
  }

//+------------------------------------------------------------------+
//|  BDSS Crossover Entry                                            |
//+------------------------------------------------------------------+
OrderAction BDSS_Simple() // Fully-tested + Fully-modified
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;
   
   int SMMA_period = 8;
   int stochastic_period = 5;

   double BDSS_Buy = iCustom(NULL,0,"BDSS",SMMA_period,stochastic_period,1,1);
   double BDSS_Sell = iCustom(NULL,0,"BDSS",SMMA_period,stochastic_period,2,1);
   double BDSS_BuyPrev = iCustom(NULL,0,"BDSS",SMMA_period,stochastic_period,1,2);
   double BDSS_SellPrev = iCustom(NULL,0,"BDSS",SMMA_period,stochastic_period,2,2);

   if(LongCrossOver(BDSS_Buy, BDSS_Sell, BDSS_BuyPrev, BDSS_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(BDSS_Buy, BDSS_Sell, BDSS_BuyPrev, BDSS_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;

  }
//+------------------------------------------------------------------+
//| Accelerator2 Crossover Entry                                     |
//+------------------------------------------------------------------+
OrderAction Accelerator2_Simple()
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double Accelerator2_Buy = iCustom(NULL,0,"Accelerator2",1,1);
   double Accelerator2_Sell = iCustom(NULL,0,"Accelerator2",2,1);
   double Accelerator2_BuyPrev = iCustom(NULL,0,"Accelerator2",1,2);
   double Accelerator2_SellPrev = iCustom(NULL,0,"Accelerator2",2,2);

   if(LongCrossOverNull(Accelerator2_Buy,Accelerator2_SellPrev))
      signal = OA_OPEN_LONG;

   if(LongCrossOverNull(Accelerator2_Sell,Accelerator2_BuyPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| EMA Baseline check                                               |
//+------------------------------------------------------------------+
OrderAction EMA_Baseline() // Fully-tested + Fully-modified
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;
   
   double MA_period = 65;
   double set_price = 0; 

   double EMA_baseline = iCustom(NULL,0,"EMA",MA_period,0.0,0,set_price,0,1);

   if(CheckForLongBaseline(EMA_baseline))
      signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(EMA_baseline))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| AMA Baseline check                                               |
//+------------------------------------------------------------------+
OrderAction AMA_Simple_Baseline() // Fully-tested + Fully-modified
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;
   
   int AMA_period = 24;
   int nfast = 2;
   int nslow = 30;
   double G = 2.0;
   double dK = 2.0;  
   
   double AMA_baseline = iCustom(NULL,0,"AMA",AMA_period, nfast, nslow, G, dK,0,1);

   if(CheckForLongBaseline(AMA_baseline))
      signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(AMA_baseline))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| Aroon Crossover Entry                                            |
//+------------------------------------------------------------------+
OrderAction Aroon_Simple() // Fully-tested + Fully-modified
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int Aroon_period = 72;

   double Aroon_Buy = iCustom(NULL,0,"Aroon",Aroon_period,false,false,0,1);
   double Aroon_Sell = iCustom(NULL,0,"Aroon",Aroon_period,false,false,1,1);
   double Aroon_BuyPrev = iCustom(NULL,0,"Aroon",Aroon_period,false,false,0,2);
   double Aroon_SellPrev = iCustom(NULL,0,"Aroon",Aroon_period,false,false,1,2);

   if(LongCrossOver(Aroon_Buy, Aroon_Sell, Aroon_BuyPrev, Aroon_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(Aroon_Buy, Aroon_Sell, Aroon_BuyPrev, Aroon_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+


enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen,    // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
  };


