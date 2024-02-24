#property copyright "Framework 4"
#property strict

#include <Tykee/main/risk.mqh>
#include <Tykee/main/riskmanager.mqh>

#include <Tykee/common/calculations.mqh>
#include <Tykee/common/enums.mqh>
#include <Tykee/common/logger.mqh>
#include <Tykee/common/session.mqh>

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
      double breakEven;
      bool fixedSLTP;
      datetime lastBarTime;
      RiskManager* riskManager;
      CustomSession* customSession;
   
   public:
      PositionManager::PositionManager(RiskManager* cRiskManager, CustomSession* cCustomSession, double cSLRatio, double cTPRatio, int cATRPeriod,double cRiskPerTrade, int cSlippage, double cBreakEven, bool cfixedSLTP) {
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
      riskManager.newTrade(positionType);
      double lotSize = riskManager.getLotSize();
      double slPrice = riskManager.getSLprice();
      double tpPrice = riskManager.getTPprice();
      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
      int number = OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red);
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
      To not complictae things, call this function from EA's swtich/case statement
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
      Checks if we have had TP/SL. If yes, closes position manually. Difference
      between closePostition() is that we actually do not close position as
      it is already automatically closed by terminal. Instead we just save it and 
      mark closed.
   */
   void onAutomaticPositionClose() {
      Logger::log("Stop loss/Take profit executed");

      if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY)) {
         Logger::log("Position closed");
      } else {
         Logger::log("Automatic close position error: " + string(GetLastError()));
      }
   }
   
   void checkBreakeven() {
      if (OrderSelect(0, SELECT_BY_POS) == true) {
         int oticket = OrderTicket();
         double oop = NormalizeDouble(OrderOpenPrice(), Digits); 
         double osl = NormalizeDouble(OrderStopLoss(), Digits);
         double otp = NormalizeDouble(OrderTakeProfit(), Digits);
         double breakevenPrice = riskManager.getBreakevenPrice();
         bool orderModify;

         if (OrderType() == OP_BUY) {
            if (Bid >= breakevenPrice || High[1] >= breakevenPrice) {
               orderModify = OrderModify(oticket, oop, oop, otp, 0, clrOrange);
            }
         } else {
            if (Ask <= breakevenPrice || Low[1] <= breakevenPrice) {
               orderModify = OrderModify(oticket, oop, oop, otp, 0, clrOrange);
            }
         }

         if (orderModify) {
            riskManager.setBreakeven();
            Logger::log("Breakeven set");
         } else {
            Logger::log("Break even error: " + string(GetLastError()));
         }
      } else {
         Logger::log("Could not access last historical order... ErrorCode= " + string(GetLastError()));
      }
   }

   void checkProfitZone() {
      if (OrderSelect(0, SELECT_BY_POS) == true) {
         int oticket = OrderTicket();
         double oop = NormalizeDouble(OrderOpenPrice(), Digits); 
         double otp = NormalizeDouble(OrderTakeProfit(), Digits);
         double profitZonePrice = riskManager.getProfitZonePrice();
         double newSL = riskManager.getProfitZoneSLPrice();
         bool orderModify;

         if (OrderType() == OP_BUY) {
            if (Bid >= profitZonePrice || High[1] >= profitZonePrice) {
               orderModify = OrderModify(oticket, oop, newSL, otp, 0, clrWhite);
            }
         } else {
            if (Ask <= profitZonePrice || Low[1] <= profitZonePrice) {
               orderModify = OrderModify(oticket, oop, newSL, otp, 0, clrWhite);
            }
         }

         if (orderModify) {
            riskManager.setProfitZone();
            Logger::log("Profit zone set");
         } else {
            Logger::log("Profit zone error: " + string(GetLastError()));
         }

      } else {
         Logger::log("Could not access last historical order... ErrorCode= " + string(GetLastError()));
      }
   }
   

   PositionStatus getStatus() {
      switch (OrdersTotal()) {
         case 0:
            Logger::log("PositionStatus.getStatus() - AVAILABLE_TO_OPEN"); 
            return AVAILABLE_TO_OPEN;
            break;

         case 1:
            if (!riskManager.getBreakeven()) {
               checkBreakeven();
               Logger::log("PositionStatus.getStatus() - checkBreakeven() True");
            } else if(riskManager.getBreakeven() && !riskManager.getProfitZone()) {
               checkProfitZone();
               Logger::log("PositionStatus.getStatus() - checkProfitZone() True");
            }

            Logger::log("PositionStatus.getStatus() - IS_OPENED");
            return IS_OPENED;
            break;

         default:
            Logger::log("PositionStatus.getStatus() Switch exit Default");
            break;
         }
      return true;
   }
};
