//+------------------------------------------------------------------+
//|                                                         exit.mqh |
//|                                            Copyright 2022, Tykee |
//+------------------------------------------------------------------+
#property copyright "IKAR"
#property link      ""
#property strict

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>
//+------------------------------------------------------------------+
//| Relative Vigor Index (RVI) Crossover Exit                        |
//+------------------------------------------------------------------+
OrderAction ExitRVI()
  {

   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double RVIBuy = iCustom(NULL,0,"RelativeVigorIndex",0,1);
   double RVISell = iCustom(NULL,0,"RelativeVigorIndex",1,1);
   double RVIBuyPrev = iCustom(NULL,0,"RelativeVigorIndex",0,2);
   double RVISellPrev = iCustom(NULL,0,"RelativeVigorIndex",1,2);

   if(LongCrossOver(RVIBuy, RVISell, RVIBuyPrev, RVISellPrev))
     {
      signal = OA_CLOSE;
     }
   else
      if(ShortCrossOver(RVIBuy, RVISell, RVIBuyPrev, RVISellPrev))
        {
         signal = OA_CLOSE;
        }

   return signal;
  }

//+------------------------------------------------------------------+
//| Crossover exit for Trend Envelopes                               |
//+------------------------------------------------------------------+
