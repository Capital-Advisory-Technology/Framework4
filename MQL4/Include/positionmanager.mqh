

#include <calculations.mqh>
#include <position.mqh>
#include <backtest.mqh>
#include <enums.mqh>

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
      Position* openPosition;
      BacktestInfo* backtestInfo;
     
   public:
      PositionManager::PositionManager(BacktestInfo* cBacktestInfo, double cSLRatio, double cTPRatio, double cRiskPerTrade, int cSlippage) {
        this.backtestInfo = cBacktestInfo;
        this.riskPerTrade = cRiskPerTrade;
        this.SLRatio = cSLRatio;
        this.TPRatio = cTPRatio;
        this.slippage = cSlippage;
        this.openPosition = NULL;
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
      
      double SMA200 = iMA(Symbol(),Period(), 200, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA200 = iMA(Symbol(), Period(), 200, 0, MODE_EMA, PRICE_CLOSE, 0);
      double SMA65 = iMA(Symbol(), Period(), 65, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA65 = iMA(Symbol(), Period(), 65, 0, MODE_EMA, PRICE_CLOSE, 0);
      double RSI14 = iRSI(Symbol(), Period(), 14, PRICE_CLOSE, 0);
      double ATR14 = iATR(Symbol(), Period(), 14, 0);
      
      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
      int number = OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red);
      Print("Opened order number: " + string(number));
      if  (number != -1) {
         Print("Order send success");
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
            Print("Select position error: ", string(GetLastError()));
         }
      } else {
         Print("Open position error: ", string(GetLastError()));
      }  
   };
   
   void closePosition() {
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
       
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
          Print("Position closed");
          openPosition.setPositionClosed(OrderCloseTime(), price, OrderProfit());
          backtestInfo.savePosition(openPosition);
          openPosition = NULL;
      } else {
         Print("Close position error: ", string(GetLastError()));
      }
   }
   
   void onAutomaticPositionClose() {
      Print("Stop loss/Take profit executed");
      if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY)) {
         Print("Position closed");
         openPosition.setPositionClosed(OrderCloseTime(), OrderClosePrice(), OrderProfit());
         backtestInfo.savePosition(openPosition);
         openPosition = NULL;
      } else {
        Print("Automatic close position error: ", string(GetLastError()));
      }
   }
   
   bool isPositionOpen() {
      return openPosition != NULL;
   }
   
   PositionStatus getStatus() {
      if (isPositionOpen() && OrdersTotal() == 0) {
        onAutomaticPositionClose();
         return AVAILABLE_TO_OPEN;
      } else if (!isPositionOpen() && OrdersTotal() == 0){
         return AVAILABLE_TO_OPEN;
      } else if(isPositionOpen()) {
         return IS_OPENED;
      } else {
         return IS_OPENED;
      }
   }
};
