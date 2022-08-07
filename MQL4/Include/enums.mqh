//+------------------------------------------------------------------+
//|                                                        enums.mqh |
//|                                             Copyright 2022, IKAR |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, IKAR"
#property link      ""

enum OrderAction 
{
   OA_OPEN_LONG,
   OA_OPEN_SHORT,
   OA_CLOSE,
   OA_IGNORE   
};

enum ExternalNames 
{
   RISK_PER_TRADE,
   SL_RATIO,
   TP_RATIO,
   SLIPPAGE
};

enum PositionStatus 
{
   AVAILABLE_TO_OPEN,
   IS_OPENED
};

