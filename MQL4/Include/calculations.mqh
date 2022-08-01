//+------------------------------------------------------------------+
//|                                                 calculations.mqh |
//|                                                             IKAR |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "IKAR"
#property link      ""
#property strict


//+------------------------------------------------------------------+
//| Calculates LotSize based on balance, risk and StopLoss           |
//+------------------------------------------------------------------+
double CalculateLotSize(double balance, double risk, int stopLoss)
  {
   Print("Balance: " + balance + " Risk: " + risk + " SL: " + stopLoss);
   double lotStep = MarketInfo(Symbol(),MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(),MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(),MODE_MAXLOT);
   double tickVal = MarketInfo(Symbol(),MODE_TICKVALUE);

   double lotSize = balance * risk / 100 / (stopLoss * tickVal);

   return MathMin(
             maxLot,
             MathMax(minLot,
                     NormalizeDouble(lotSize / lotStep,0) * lotStep)
          );
  }

//+------------------------------------------------------------------+
//| Calculates StopLoss or TakeProfit                                |
//+------------------------------------------------------------------+
int CalculateSLTP(double stopLossRatio, double takeProfitRatio, int variable)
  {
   double atr=iCustom(NULL,0,"Adaptive_ATR",0,1);
   int result;

   switch(variable)
     {
      case 0:
         result = (int)(atr * stopLossRatio/Point);
         break;
      case 1:
         result = (int)(atr * takeProfitRatio/Point);
         break;
      default:
         result = 0;
         break;
     }
   return result;
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
