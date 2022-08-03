

#include <calculations.mqh>
#include <position.mqh>
#include <backtest.mqh>

/** MOST IMPORTANT NOTE
* DO NOT SPAM "OrderSelect" across separate files. Now, as we have MAX
* one position at any given time, "OrderSelect" is called only after order is opened.
* The OrderSelect instance variables are used accross multiple functions and if you select different
* order at incorrect time, you WILL mess up values. If you want to implement multiple open 
* orders at once, talk with Ralfs.
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
      
      double SMA200 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA200 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
      double SMA65 = iMA(NULL, 0, 65, 0, MODE_SMA, PRICE_CLOSE, 0);
      double EMA65 = iMA(NULL, 0, 65, 0, MODE_EMA, PRICE_CLOSE, 0);
      double RSI14 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
      double ATR14 = iATR(NULL, 0, 14, 0);
      
      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      int number = OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red);
      Print("Opened order number: " + number);
      
      if  (number != -1) {
         Print("Position send success");
         if (OrderSelect(0, SELECT_BY_POS)) {
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
         } else {
            Print("Select position error: " + string(GetLastError()));
         }
      } else {
         Print("Open position error: " + string(GetLastError()));
      }  
   };
   
   void closePosition() {
      Print("Manual position close");
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
       
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
          Print("Position closed");
          openPosition.setPositionClosed(OrderCloseTime(), price, OrderProfit());
          backtestInfo.savePosition(openPosition);
          openPosition = NULL;
      } else {
         Print("Close position error: " + string(GetLastError()));
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
        Print("Automatic close position error: " + string(GetLastError()));
      }
   }
   
    bool isPositionOpen() {
      return openPosition != NULL;
   }
};