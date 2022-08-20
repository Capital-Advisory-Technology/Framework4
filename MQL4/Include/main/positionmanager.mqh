#include <common/calculations.mqh>
#include <common/position.mqh>
#include <main/backtest.mqh>
#include <common/enums.mqh>
#include <main/risk.mqh>
#include <common/logger.mqh>

/** MOST IMPORTANT NOTE
* DO NOT SPAM "OrderSelect" across separate files. As we have MAX
* one position at any given time, "OrderSelect" is called only after order is opened.
* The OrderSelect instance variables are used accross multiple functions and if you select different
* order at incorrect time, you WILL mess up values. If you want to implement multiple open 
* orders at once, talk with Ralfs or Lielais.
**/
class PositionManager {

   private:
      double riskPerTrade;
      double SLRatio;
      double TPRatio;
      int slippage;
      double breakEven;
      Position* openPosition;
      BacktestInfo* backtestInfo;
     
   public:
      PositionManager::PositionManager(BacktestInfo* cBacktestInfo, double cSLRatio, double cTPRatio, double cRiskPerTrade, int cSlippage, double cBreakEven) {
        this.backtestInfo = cBacktestInfo;
        this.riskPerTrade = cRiskPerTrade;
        this.SLRatio = cSLRatio;
        this.TPRatio = cTPRatio;
        this.slippage = cSlippage;
        this.openPosition = NULL;
        this.breakEven = cBreakEven;
      }
      
      ~ PositionManager() {
         delete openPosition;
      }
    
   void openOrder(int positionType) {
      int stopLoss = CalculateSLTP(SLRatio, TPRatio, 0);
      int takeProfit = CalculateSLTP(SLRatio, TPRatio, 1);
      double lotSize = CalculateLotSize(AccountBalance(), riskPerTrade, stopLoss);
      double slPrice = GetSLprice(stopLoss, positionType);
      double tpPrice = GetTPprice(takeProfit, positionType);
      
      double SMA200 = iMA(Symbol(),Period(), 200, 0, MODE_SMA, PRICE_CLOSE, 1);
      double EMA200 = iMA(Symbol(), Period(), 200, 0, MODE_EMA, PRICE_CLOSE, 1);
      double SMA65 = iMA(Symbol(), Period(), 65, 0, MODE_SMA, PRICE_CLOSE, 1);
      double EMA65 = iMA(Symbol(), Period(), 65, 0, MODE_EMA, PRICE_CLOSE, 1);
      double RSI14 = iRSI(Symbol(), Period(), 14, PRICE_CLOSE, 1);
      double ATR14 = iATR(Symbol(), Period(), 14, 1);
      
      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
      int number = OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red);
      Logger::log("Opened order number: " + string(number));
      if  (number != -1) {
         Logger::log("Order send success");
         if (OrderSelect(0, SELECT_BY_POS)) {
            openPosition = new Position(
               number,
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
         } else {
           Logger::log("Select position error: " + string(GetLastError()));
         }
      } else {
         Logger::log("Open position error: " + string(GetLastError()));
      }  
   };
   
   void closePosition() {
      if (openPosition == NULL) return;
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
          OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY);
          Logger::log("Position closed");
          openPosition.setPositionClosed(OrderCloseTime(), price, OrderProfit(), MANUAL_CLOSE);
          backtestInfo.savePosition(openPosition);
          openPosition = NULL;
      } else {
         Logger::log("Close position error: " + string(GetLastError()));
      }
   }
   
   void onAutomaticPositionClose() {
      Logger::log("Stop loss/Take profit executed");
      if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY)) {
         Logger::log("Position closed");
         openPosition.setPositionClosed(OrderCloseTime(), OrderClosePrice(), OrderProfit(), AUTOMATIC_CLOSE);
         backtestInfo.savePosition(openPosition);
         openPosition = NULL;
      } else {
        Logger::log("Automatic close position error: " + string(GetLastError()));
      }
   }
   
   bool isPositionOpen() {
      return openPosition != NULL;
   }
   
   void onDeInit() {
      if (isPositionOpen()) {
         if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY)) {
            double price;
            if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
               openPosition.setPositionClosed(OrderCloseTime(), price, OrderProfit(), AUTOMATIC_CLOSE);
               backtestInfo.savePosition(openPosition);
         }
      }
   }
   
   PositionStatus getStatus() {
      if (isPositionOpen() && OrdersTotal() == 0) {
        onAutomaticPositionClose();
         return AVAILABLE_TO_OPEN;
      } else if (!isPositionOpen() && OrdersTotal() == 0){
         return AVAILABLE_TO_OPEN;
      } else if(isPositionOpen()) {
         if (CheckForBreakEven(breakEven) && !openPosition.getBreakEvenFlag()) {
            openPosition.updateStopLoss();
            openPosition.setBreakEvenFlag(true);
         }
         return IS_OPENED;
      } else {
         return IS_OPENED;
      }
   }
};
