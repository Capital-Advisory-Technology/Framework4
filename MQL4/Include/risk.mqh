//+------------------------------------------------------------------+
//|                                                         risk.mqh |
//|                                            Copyright 2022, Tykee |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//|   TODO:    Add comparison with High/Low to reduce slippage       |
//+------------------------------------------------------------------+
void TestBreakEven(int breakeven) {
   
   OrderSelect(0, SELECT_BY_POS);
   //int ticket = OrderTicket();
   //double op = OrderOpenPrice();
   //double tp = OrderTakeProfit();
   //double sl = OrderStopLoss();
   
   double BreakEvenPrice;
    
   if (OrderType() == OP_BUY) { 
      BreakEvenPrice = NormalizeDouble(((OrderTakeProfit() - OrderOpenPrice()) / breakeven + OrderOpenPrice()),Digits);         
         if (Bid >= BreakEvenPrice) {      
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrOrange);      
         }
   } else {
      BreakEvenPrice = NormalizeDouble((OrderOpenPrice() - (OrderOpenPrice() - OrderTakeProfit()) / breakeven),Digits);
         if (Ask <= BreakEvenPrice) {      
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrOrange);
         }
   } 
}

