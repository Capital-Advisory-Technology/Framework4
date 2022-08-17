//+------------------------------------------------------------------+
//|                                                         risk.mqh |
//|                                            Copyright 2022, Tykee |
//|   risk.mqh provides functions that are used for risk management  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//|   TODO:    Add comparison with High/Low to reduce slippage       |
//+------------------------------------------------------------------+

bool CheckForBreakEven(double breakeven) {
   
   OrderSelect(0, SELECT_BY_POS);
   double high = iHigh(OrderSymbol(), PERIOD_CURRENT,1);   
   double low = iLow(OrderSymbol(), PERIOD_CURRENT,1);
      
   if (OrderOpenPrice() == OrderStopLoss()) return false;
   
   double BreakEvenPrice;
    
   if (OrderType() == OP_BUY) { 
      BreakEvenPrice = NormalizeDouble(((OrderTakeProfit() - OrderOpenPrice()) * breakeven + OrderOpenPrice()), Digits);         
         if (Bid >= BreakEvenPrice || high >= BreakEvenPrice) {
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrOrange);
            return true;      
         }
   } else {
      BreakEvenPrice = NormalizeDouble((OrderOpenPrice() - (OrderOpenPrice() - OrderTakeProfit()) * breakeven), Digits);
         if (Ask <= BreakEvenPrice || low <= BreakEvenPrice) {
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrOrange);
            return true;
         }
   }
   return false;
}
