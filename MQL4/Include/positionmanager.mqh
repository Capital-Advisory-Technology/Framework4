

#include <calculations.mqh>
#include <position.mqh>
#include <backtest.mqh>

class PositionManager {

   private:
      double riskPerTrade;
      double SLRatio;
      double TPRatio;
      int slippage;
      Position* openPosition;
      BacktestInfo* backtestInfo;
     
 
   public:
    PositionManager::PositionManager(BacktestInfo* backtestInfo, double slRatio, double tpRatio, double riskPerTrade, int slippage) {
      this.backtestInfo = backtestInfo;
      this.riskPerTrade = riskPerTrade;
      this.SLRatio = slRatio;
      this.TPRatio = tpRatio;
      this.slippage = slippage;
   }

   void openOrder(int positionType) {
      int stopLoss = CalculateSLTP(SLRatio, TPRatio, 0);
      int takeProfit = CalculateSLTP(SLRatio, TPRatio, 1);
      double lotSize = CalculateLotSize(AccountBalance(), riskPerTrade, stopLoss);
      double slPrice = GetSLprice(stopLoss, positionType);
      double tpPrice = GetTPprice(takeProfit, positionType);
      
      double SMA200 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA200 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
      double SMA65 = iMA(NULL, 0, 65, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
      double RSI14 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
      double ATR14 = iATR(NULL, 0, 14, 0);
      
      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
        // we have stop loss price - so it is close price. need to just call it
      if (OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red) != -1) {
         OrderSelect(0, SELECT_BY_POS);
         openPosition = new Position(
            OrderOpenTime(), 
            positionType, 
            lotSize, 
            OrderOpenPrice(), 
            slPrice, 
            tpPrice, 
            SMA200, 
            EMA200, 
            SMA65, 
            EMA65,
            RSI14, 
            ATR14
         );
      }
   };
   
   void closePosition() {
      // check if this order select is correct 
      OrderSelect(0, SELECT_BY_POS);
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
       
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
      
          openPosition.setPositionClosed(OrderCloseTime(), price, OrderProfit());
          backtestInfo.savePosition(openPosition);
          openPosition = NULL;
      } else {
         Print("Close position error: " + GetLastError());
      }
      
   }
   
   void onAutomaticPositionClose() {
      if (OrderSelect(OrdersHistoryTotal(), SELECT_BY_POS, MODE_HISTORY)) {
         openPosition.setPositionClosed(OrderCloseTime(), OrderClosePrice(), OrderProfit());
         backtestInfo.savePosition(openPosition);
         openPosition = NULL;
      } else {
         Print("Automatic close position error: " + GetLastError());
      }
   }
   
    bool isPositionOpen() {
      return openPosition != NULL;
   }

};