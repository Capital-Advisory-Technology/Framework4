//+------------------------------------------------------------------+
//|                                                        entry.mqh |
//|                                                             IKAR |
//+------------------------------------------------------------------+

#include <enums.mqh>
#include <utils.mqh>
//+------------------------------------------------------------------+
//| Trend Envelope (TE) Crossover Entry                              |
//+------------------------------------------------------------------+
OrderAction TrendEnvelopeEntrySingle()
  {

   RefreshRates();
   OrderAction signal = OA_IGNORE;

   double TEBuy = iCustom(NULL,0,"TrendEnvelope",0,1);
   double TESell = iCustom(NULL,0,"TrendEnvelope",1,1);
   double TEBuyPrev = iCustom(NULL,0,"TrendEnvelope",0,2);
   double TESellPrev = iCustom(NULL,0,"TrendEnvelope",1,2);

   if(LongCrossOver(TEBuy, TESell, TEBuyPrev, TESellPrev))
     {
      signal = OA_OPEN_LONG;
     }
   else
      if(ShortCrossOver(TEBuy, TESell, TEBuyPrev, TESellPrev))
        {
         signal = OA_OPEN_SHORT;
        }

   return signal;

  }
//+-----;-------------------------------------------------------------+
