//+------------------------------------------------------------------+
//|                                                        enums.mqh |
//|                                            Copyright 2022, Tykee |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""

enum OrderAction 
{
   OA_OPEN_LONG,
   OA_OPEN_SHORT,
   OA_CONFIRMED,
   OA_CLOSE,
   OA_IGNORE   
};

enum AllowedOrder 
{
   OPEN_LONG = 0,
   OPEN_SHORT = 1,
   OPEN_BOTH = 2 
};

enum ExternalNames 
{
   RISK_PER_TRADE,
   SL_RATIO,
   TP_RATIO,
   FIXED_SLTP,
   SLIPPAGE,
   BREAK_EVEN,
   USE_EXIT
};

enum PositionStatus 
{
   AVAILABLE_TO_OPEN,
   IS_OPENED
};

enum CloseType 
{
   MANUAL_CLOSE = 0,
   AUTOMATIC_CLOSE = 1
};
