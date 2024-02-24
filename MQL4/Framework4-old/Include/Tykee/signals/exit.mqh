//+-------------------------------------------------------------------+
//|                                                          exit.mqh |
//|                                             Copyright 2022, Tykee |
//| Functions used as exits when building a model.                    |
//| Commented above the function is QC for Quality Control &          |
//| Function variables with suggested ranges, note that {}            |
//| means flexible & [] means fixed (including)                       |
//| Note: Consult Artūrs jr. for suggestions since unlimited or large |
//| range doesn't mean it's supposed to be used                       |
//+-------------------------------------------------------------------+
#property copyright "Tykee"
#property link      ""
#property strict

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>
#include <Tykee/main/positionmanager.mqh>
#include <Tykee/main/backtest.mqh>

//| Relative Vigor Index (RVI) Crossover Exit (QC)
//| RVI_period - {14 - 28}
OrderAction ExitRVI(int RVI_period)
  {
   addToExitFunctionList("ExitRVI");
   OrderAction signal = OA_IGNORE;

   double RVIBuy = iCustom(NULL,0,"RelativeVigorIndex",RVI_period,0,1);
   double RVISell = iCustom(NULL,0,"RelativeVigorIndex",RVI_period,1,1);
   double RVIBuyPrev = iCustom(NULL,0,"RelativeVigorIndex",RVI_period,0,2);
   double RVISellPrev = iCustom(NULL,0,"RelativeVigorIndex",RVI_period,1,2);
   
   if(openPositionType == 0) {
      if(ShortCrossOver(RVIBuy, RVISell, RVIBuyPrev, RVISellPrev)) signal = OA_CLOSE;  
   } else if (openPositionType == 1) {
      if(LongCrossOver(RVIBuy, RVISell, RVIBuyPrev, RVISellPrev)) signal = OA_CLOSE;
   }

   return signal;
  }

