//+------------------------------------------------------------------+
//|                                                 calculations.mqh |
//|                                                            Tykee |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Tykee"
#property link      ""
#property strict


//+------------------------------------------------------------------+
//| Calculates LotSize based on balance, risk and StopLoss           |
//+------------------------------------------------------------------+
double CalculateLotSize(double risk, int stopLoss)
  {
   double lotStep = MarketInfo(Symbol(),MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(),MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(),MODE_MAXLOT);
   double tickVal = MarketInfo(Symbol(),MODE_TICKVALUE);
   double lotSize = AccountBalance() * risk / 100 / (stopLoss * tickVal);
   return MathMin(maxLot, MathMax(minLot,NormalizeDouble(lotSize / lotStep, 0) * lotStep));
  }

//+------------------------------------------------------------------+
//| Calculates StopLoss or TakeProfit                                |
//+------------------------------------------------------------------+
int CalculateSL(double stopLossRatio, bool fixed) {
  int stopLoss;
  if(fixed) stopLoss = (int)MathRound(stopLossRatio);
  else {
    double atr=iCustom(NULL, Period(), "Adaptive_ATR", 0, 1); 
    stopLoss = (int)(atr / Point * stopLossRatio);
  }

  return stopLoss;
}

int CalculateTP(double takeProfitRatio, bool fixed) {
  int takeProfit;
  if(fixed) takeProfit = (int)MathRound(takeProfitRatio);
  else {
    double atr=iCustom(NULL, Period(), "Adaptive_ATR", 0, 1);
    takeProfit = (int)(atr / Point * takeProfitRatio);
  }

  return takeProfit;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSLprice(int stopLoss, int orderType)
  {
   double price = .0;

   switch(orderType)
     {
      case OP_BUY:
         price = NormalizeDouble(Ask-stopLoss*Point, Digits);
         break;
      case OP_SELL:
         price = NormalizeDouble(Bid+stopLoss*Point, Digits);
         break;
     }
   return price;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTPprice(int takeProfit, int orderType)
  {
   double price = .0;

   switch(orderType)
     {
      case OP_BUY:
         price = NormalizeDouble(Ask+takeProfit*Point, Digits);
         break;
      case OP_SELL:
         price = NormalizeDouble(Bid-takeProfit*Point, Digits);
         break;
     }
   return price;
  }
//+------------------------------------------------------------------+
