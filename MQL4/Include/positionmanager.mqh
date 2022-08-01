

#include <calculations.mqh>
#include <position.mqh>
#include <backtest.mqh>

class PositionManager {

   private:
      double riskPerTrade;
      double SLRatio;
      double TPRatio;
      Position* openPosition;
      BacktestInfo* backtestInfo;
     
 
   public:
    PositionManager::PositionManager(BacktestInfo* backtestInfo, double slRatio, double tpRatio, double riskPerTrade) {
      this.backtestInfo = backtestInfo;
      this.riskPerTrade = riskPerTrade;
      this.SLRatio = slRatio;
      this.TPRatio = tpRatio;
   }

   void openOrder(long openTime, int positionType) {
      int stopLoss = CalculateSLTP(SLRatio, TPRatio, 0);
      int takeProfit = CalculateSLTP(SLRatio, TPRatio, 1);
      double lotSize = CalculateLotSize(AccountBalance(), riskPerTrade, stopLoss);
      double slPrice = GetSLprice(stopLoss, positionType);
      double tpPrice = GetTPprice(takeProfit, positionType);
      double openPrice;
      
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
      double SMA200 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA200 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
      double SMA65 = iMA(NULL, 0, 65, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
      double RSI14 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
      double ATR14 = iATR(NULL, 0, 14, 0);
      
        // we have stop loss price - so it is close price. need to just call it
      if (OrderSend(Symbol(), positionType, lotSize, openPrice, 3, slPrice, tpPrice, "Comment", 0, 0, Red) != -1) {
         openPosition = new Position(
            openTime, 
            positionType, 
            lotSize, 
            openPrice, 
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
   
   void closePosition(long closeTime) {
      OrderSelect(0, SELECT_BY_POS);
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
       
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
          openPosition.setPositionClosed(closeTime, price, OrderProfit());
          backtestInfo.savePosition(openPosition);
          openPosition = NULL;
      }
   }
   
   void onAutomaticPositionClose(long closeTime) {
      openPosition.setPositionClosed(closeTime, openPosition.getSlPrice(), OrderProfit());
      backtestInfo.savePosition(openPosition);
      openPosition = NULL;
   }
   
   
    bool isPositionOpen() {
      return openPosition != NULL;
   }

};