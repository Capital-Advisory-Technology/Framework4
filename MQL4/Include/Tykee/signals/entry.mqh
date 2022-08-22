//+------------------------------------------------------------------+
//|                                                        entry.mqh |
//|                                                             IKAR |
//+------------------------------------------------------------------+

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>

//+------------------------------------------------------------------+
//| Trend Envelope (TE) Crossover Entry                              |
//+------------------------------------------------------------------+
OrderAction TE_Simple()
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double TE_Buy = iCustom(NULL,0,"TrendEnvelope",0,1);
   double TE_Sell = iCustom(NULL,0,"TrendEnvelope",1,1);
   double TE_BuyPrev = iCustom(NULL,0,"TrendEnvelope",0,2);
   double TE_SellPrev = iCustom(NULL,0,"TrendEnvelope",1,2);

   if(LongCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(TE_Buy, TE_Sell, TE_BuyPrev, TE_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;

  }

//+------------------------------------------------------------------+
//|  BDSS Crossover Entry                                            |
//+------------------------------------------------------------------+
OrderAction BDSS_Simple()
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double BDSS_Buy = iCustom(NULL,0,"BDSS",1,1);
   double BDSS_Sell = iCustom(NULL,0,"BDSS",2,1);
   double BDSS_BuyPrev = iCustom(NULL,0,"BDSS",1,2);
   double BDSS_SellPrev = iCustom(NULL,0,"BDSS",2,2);

   if(LongCrossOver(BDSS_Buy, BDSS_Sell, BDSS_BuyPrev, BDSS_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(BDSS_Buy, BDSS_Sell, BDSS_BuyPrev, BDSS_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;

  }
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
OrderAction AMA_Simple_Baseline()
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double AMA_baseline = iCustom(NULL,0,"AMA",0,1);

   if(CheckForLongBaseline(AMA_baseline))
      signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(AMA_baseline))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
OrderAction Aroon_Simple() 
{
   RefreshRates();
   OrderAction signal = OA_IGNORE;
   
   double Aroon_Buy = iCustom(NULL,0,"Aroon",0,1);
   double Aroon_Sell = iCustom(NULL,0,"Aroon",1,1);
   double Aroon_BuyPrev = iCustom(NULL,0,"Aroon",0,2);
   double Aroon_SellPrev = iCustom(NULL,0,"Aroon",1,2);

   if(LongCrossOver(Aroon_Buy, Aroon_Sell, Aroon_BuyPrev, Aroon_SellPrev))
      signal = OA_OPEN_LONG;

   if(ShortCrossOver(Aroon_Buy, Aroon_Sell, Aroon_BuyPrev, Aroon_SellPrev))
      signal = OA_OPEN_SHORT;

   return signal;
   

}