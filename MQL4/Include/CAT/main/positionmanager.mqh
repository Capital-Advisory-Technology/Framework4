#property copyright "Framework 4"
#property strict

#include <CAT/main/riskmanager.mqh>

#include <CAT/common/enums.mqh>
#include <CAT/common/logger.mqh>
#include <CAT/common/session.mqh>

static int openPositionType;

/*
   Position manager meant for controlling when we can open/close position. 
   This class should be initialized in EA's onInit() function. PositionManager is linked together
   with Backtest instance.
   
   Important note if you decide to modify this class:
       DO NOT SPAM "OrderSelect" across separate files. As we have MAX
       one position at any given time, "OrderSelect" is called only after order is opened.
       The global OrderSelect instance is used accross multiple functions and files and if you select different
       order at incorrect time, you WILL mess up values.
*/
class PositionManager {

   private:
      double riskPerTrade;
      double SLRatio;
      double TPRatio;
      int ATRPeriod;
      int slippage;
      int maxOpenPositions;
      double breakEven;
      bool fixedSLTP;
      datetime lastBarTime;
      RiskManager* riskManager;
      CustomSession* customSession;
   
   public:
      PositionManager::PositionManager(RiskManager* cRiskManager, CustomSession* cCustomSession, double cSLRatio, double cTPRatio, int cATRPeriod,double cRiskPerTrade, int cSlippage, double cBreakEven, bool cfixedSLTP, int cMaxOpenPositions = 1) {
        this.riskManager = cRiskManager;
        this.riskPerTrade = cRiskPerTrade;
        this.SLRatio = cSLRatio;
        this.TPRatio = cTPRatio;
        this.ATRPeriod = cATRPeriod;
        this.slippage = cSlippage;
        this.lastBarTime = Time[0];
        this.breakEven = cBreakEven;
        this.fixedSLTP = cfixedSLTP;
        this.customSession = cCustomSession;
        this.maxOpenPositions = cMaxOpenPositions;
      }
      
      ~PositionManager() {
         delete customSession;
         delete riskManager;
      }
    
   /*
      Open order. TP/SL is calculted according to externals.
      To not complictae things, call this function from EA's switch/case statement
      where we check if there are no other positions open. If you decide 
      to call this function from other parts of code, you might open multiple 
      positions at once.
   */
   void openOrder(int positionType) {
      if (!customSession.allowToOpen(positionType)) return;
      // Calculate values for order
      NewTrade trade = riskManager.getNewTrade(positionType);
      Logger::log("Open Order: " + string(trade.positionType) + " Lot Size: " + string(trade.lotSize) + " Open Price: " + string(trade.openPrice) + " SL: " + string(trade.slPrice) + " TP: " + string(trade.tpPrice));

      int number = OrderSend(Symbol(), positionType, trade.lotSize, trade.openPrice, slippage, trade.slPrice, trade.tpPrice, "Comment", 0, 0, Red);
      Logger::log("Opened order number: " + string(number));
      
      if  (number != -1) {
         Logger::log("Order send success");
         if (OrderSelect(0, SELECT_BY_POS)) {
            openPositionType = positionType;
            customSession.onPositionOpened();
         } else {
           Logger::log("Select position error: " + string(GetLastError()));
         }
      } else {
         Logger::log("Open position error: " + string(GetLastError()));
      }  
   };
   
    /*
      Close order. 
      To not complicate things, call this function from EA's switch/case statement
      Where we check if there are open positions. Used only for manual closing i.e. in EA's 
      IS_OPENED block.
   */
   void closePosition() {
      if (OrdersTotal() == 0) return;

      double price;

      if (OrderType() == OP_BUY) price = Bid; else price = Ask;
      
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
         if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY) == true) {
            Logger::log("Position closed");
         } else {
            Logger::log("Could not access last historical order... ErrorCode= " + string(GetLastError()));
         }
      } else {
         Logger::log("Close position error: " + string(GetLastError()));
      }
   }
   
   /*
      Check and can set breakeven or profit zone for a position.
      This function is called from getStatus() function.
   */
   void checkBreakevenProfit() {
      int orderType = OrderType();

      double oop = NormalizeDouble(OrderOpenPrice(), Digits); 
      double osl = NormalizeDouble(OrderStopLoss(), Digits);
      double otp = NormalizeDouble(OrderTakeProfit(), Digits);

      bool isBreakeven = riskManager.getBreakevenStatus(orderType, oop, otp);
      bool isProfitZone = riskManager.getProfitZoneStatus(orderType, oop, otp);

      // Check for breakeven
      if (isBreakeven && ((orderType == OP_BUY && osl < oop) || (orderType == OP_SELL && osl > oop))) {
         bool orderModify = OrderModify(OrderTicket(), oop, oop, otp, 0, clrOrange);
         if (orderModify) Logger::log("PositionManager.checkBreakevenProfit() - Breakeven set");
         else Logger::log("PositionManager.checkBreakevenProfit() - Break even error: " + string(GetLastError()));
      }
      
      // Check for profit zone
      if (isProfitZone && osl == oop) {
         double nsl = riskManager.getProfitZoneSL(orderType, oop, otp);
         bool orderModify = OrderModify(OrderTicket(), oop, nsl, otp, 0, clrWhite);
         if (orderModify) Logger::log("PositionManager.checkBreakevenProfit() - Profit zone set");
         else Logger::log("PositionManager.checkBreakevenProfit() - Profit zone error: " + string(GetLastError()));
      }
   }

   PositionStatus getStatus() {
      int ordersTotal = OrdersTotal();
      if (ordersTotal > 0) {
         for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
            if (OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) && OrderSymbol() == Symbol()) {   
               checkBreakevenProfit();
            }; 
         }
         if (ordersTotal >= maxOpenPositions) {
            Logger::log("PositionManager.getStatus() - MULTIPLE_POSITIONS");
            return IS_OPENED;
         }
         Logger::log("PositionManager.getStatus() - IS_OPENED"); 
         return AVAILABLE_TO_OPEN;
      } else {
         Logger::log("PositionManager.getStatus() - AVAILABLE_TO_OPEN");
         return AVAILABLE_TO_OPEN;
      }
   }
};
