//+------------------------------------------------------------------+
//|                                                        utils.mqh |
//|                                             Copyright 2022, IKAR |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, IKAR"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LongCrossOver(double buy, double sell, double buyPrev, double sellPrev)
  {
   return buy > sell && sellPrev > buyPrev;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShortCrossOver(double buy, double sell, double buyPrev, double sellPrev)
  {
   return sell > buy && buyPrev > sellPrev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
bool CheckForLong(double buy, double sell) 
{
   return buy > sell;   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckForShort(double buy, double sell) 
{
   return sell > buy;   
}