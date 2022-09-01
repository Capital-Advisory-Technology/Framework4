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

// AMA Baseline check (TESTED & MODIFIED)                           
OrderAction AMA_Simple_Baseline(int AMA_period, int AMA_nfast, int AMA_nslow, double AMA_g, double AMA_dK) 
  {
   OrderAction signal = OA_IGNORE;

   double AMA_baseline = iCustom(NULL, 0, "AMA", AMA_period, AMA_nfast, AMA_nslow, AMA_g, AMA_dK, 0, 1);

   if(CheckForLongBaseline(AMA_baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(AMA_baseline)) signal = OA_OPEN_SHORT;

   return signal;
  }

// EMA Baseline check (TESTED & MODIFIED)                           
OrderAction EMA_Baseline(double EMA_period, double EMA_set_price) 
  {
   OrderAction signal = OA_IGNORE;

   double EMA_baseline = iCustom(NULL, 0, "EMA", EMA_period, 0.0, 0, EMA_set_price, 0, 1);

   if(CheckForLongBaseline(EMA_baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(EMA_baseline)) signal = OA_OPEN_SHORT;

   return signal;
  }

// DEMA Baseline check (TESTED & MODIFIED)                          
OrderAction DEMA_Baseline(double DEMA_period, double DEMA_Filter, int DEMA_FilterPeriod, int DEMA_enum_price, int DEMA_enum_filter) 
  { 
   OrderAction signal = OA_IGNORE;
   enPrices DEMA_Price = DEMA_enum_price; 
   enFilterWhat DEMA_FilterOn = DEMA_enum_filter;

   double DEMA_Baseline = iCustom(NULL, 0, "DEMA", PERIOD_CURRENT, DEMA_period, DEMA_Price, DEMA_Filter, DEMA_FilterPeriod, DEMA_FilterOn, 0, 1);

   if(CheckForLongBaseline(DEMA_Baseline)) signal = OA_OPEN_LONG;
   if(CheckForShortBaseline(DEMA_Baseline)) signal = OA_OPEN_SHORT;

   return signal; 
  }
