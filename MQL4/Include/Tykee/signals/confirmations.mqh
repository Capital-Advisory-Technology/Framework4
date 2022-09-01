//+------------------------------------------------------------------+
//|                                                confirmations.mqh |
//|                                            Copyright 2022,  Tykee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict

#include <Tykee/common/enums.mqh>
#include <Tykee/common/utils.mqh>
#include <Tykee/signals/entry.mqh>

//+------------------------------------------------------------------+
//| AMA Baseline check (TESTED & MODIFIED)                           |
//+------------------------------------------------------------------+
OrderAction AMA_Simple_Baseline() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   int AMA_period = 24;
   int AMA_nfast = 2;
   int AMA_nslow = 30;
   double AMA_g = 2.0;
   double AMA_dK = 2.0;

   double AMA_baseline = iCustom(NULL, 0, "AMA", AMA_period, AMA_nfast, AMA_nslow, AMA_g, AMA_dK, 0, 1);

   if(CheckForLongBaseline(AMA_baseline))
      signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(AMA_baseline))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| EMA Baseline check (TESTED & MODIFIED)                           |
//+------------------------------------------------------------------+
OrderAction EMA_Baseline() 
  {
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double EMA_period = 65;
   double EMA_set_price = 0;

   double EMA_baseline = iCustom(NULL, 0, "EMA", EMA_period, 0.0, 0, EMA_set_price, 0, 1);

   if(CheckForLongBaseline(EMA_baseline))
      signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(EMA_baseline))
      signal = OA_OPEN_SHORT;

   return signal;
  }
//+------------------------------------------------------------------+
//| DEMA Baseline check (TESTED & MODIFIED)                          |
//+------------------------------------------------------------------+
OrderAction DEMA_Baseline() 
  { 
   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double DEMA_period = 36;
   enPrices DEMA_Price = 2;
   double DEMA_Filter = 0; 
   int DEMA_FilterPeriod = 0;
   enFilterWhat DEMA_FilterOn = flt_prc;

   double DEMA_Baseline = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_Filter, DEMA_FilterPeriod, DEMA_FilterOn, 0, 1);

   if(CheckForLongBaseline(DEMA_Baseline)) signal = OA_OPEN_LONG;

   if(CheckForShortBaseline(DEMA_Baseline)) signal = OA_OPEN_SHORT;

   return signal; 
  }

//+------------------------------------------------------------------+
