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
   double oOp = OrderOpenPrice();
   double tp = OrderTakeProfit();
   double BreakEvenPrice;
    
   if (OrderType() == OP_BUY) { 
      BreakEvenPrice = NormalizeDouble(((tp - oOp) / breakeven + oOp),Digits);
      printf(BreakEvenPrice);   
   } else {
      BreakEvenPrice = NormalizeDouble((oOp - (oOp - tp) / breakeven),Digits);
      printf(BreakEvenPrice);
   } 

}

void CheckForBreakEven(int breakEven)
  {
   double breakEvenPrice; 

   if (OrderSelect(0,SELECT_BY_POS) == true) {
      if (OrderType() == OP_BUY) {
         breakEvenPrice = NormalizeDouble((OrderTakeProfit() - OrderOpenPrice() / breakEven) + OrderOpenPrice(),Digits);
         printf(breakEvenPrice);
         if (Bid >= breakEvenPrice) {
            printf("BUY");
            printf(OrderOpenPrice());
            printf(OrderTakeProfit());
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
            printf(OrderTakeProfit());
         }
      } else {
         breakEvenPrice = NormalizeDouble(OrderOpenPrice() - (OrderOpenPrice() - OrderTakeProfit() / breakEven),Digits);
         printf(breakEvenPrice);
         if (Ask <= breakEvenPrice) {
            printf("SELL");
            printf(OrderOpenPrice());
            printf(OrderTakeProfit());
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,clrNONE);
            printf(OrderTakeProfit());
         }     
      } 
   } 

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
