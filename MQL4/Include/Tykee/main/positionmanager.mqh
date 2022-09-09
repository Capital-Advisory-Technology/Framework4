#include <Tykee/main/risk.mqh>
#include <Tykee/main/backtest.mqh>

#include <Tykee/common/calculations.mqh>
#include <Tykee/common/position.mqh>
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
      Position* openPosition;
      BacktestInfo* backtestInfo;
      CustomSession* customSession;
     
   public:
      PositionManager::PositionManager(BacktestInfo* cBacktestInfo, CustomSession* cCustomSession, double cSLRatio, double cTPRatio, int cATRPeriod,double cRiskPerTrade, int cSlippage, double cBreakEven, bool cfixedSLTP) {
        this.backtestInfo = cBacktestInfo;
        this.riskPerTrade = cRiskPerTrade;
        this.SLRatio = cSLRatio;
        this.TPRatio = cTPRatio;
        this.ATRPeriod = cATRPeriod;
        this.slippage = cSlippage;
        this.openPosition = NULL;
        this.breakEven = cBreakEven;
        this.fixedSLTP = cfixedSLTP;
        this.customSession = cCustomSession;
        backtestInfo.setCustomSessionObject(cCustomSession);
      }
      
      ~ PositionManager() {
         delete openPosition;
      }
    
   /*
      Open order. TP/SL is calculted according to externals.
      To not complictae things, call this function from EA's switch/case statement
      where we check if there are no other positions open. If you decide 
      to call this function from other parts of code, you might open multiple 
      positions at once.
   */
   void openOrder(int positionType) {
      if (!customSession.allowToOpen()) return;
      // Calculate values for order
      int stopLoss = CalculateSL(SLRatio, ATRPeriod, fixedSLTP);
      int takeProfit = CalculateTP(TPRatio, fixedSLTP);
      double lotSize = CalculateLotSize(riskPerTrade, stopLoss);
      double slPrice = GetSLprice(stopLoss, positionType);
      double tpPrice = GetTPprice(takeProfit, positionType);

      double openPrice;
      if (positionType == OP_BUY) openPrice = Ask; else openPrice = Bid;
      
      int number = OrderSend(Symbol(), positionType, lotSize, openPrice, slippage, slPrice, tpPrice, "Comment", 0, 0, Red);
      Logger::log("Opened order number: " + string(number));
      
      if  (number != -1) {
         Logger::log("Order send success");
         if (OrderSelect(0, SELECT_BY_POS)) {
            // Calculate values for analysis
            double SMA200, EMA200, SMA65, EMA65, RSI14, ATR14;
            if (backtestInfo.getShouldExportData()) {
                SMA200 = iMA(Symbol(),Period(), 200, 0, MODE_SMA, PRICE_CLOSE, 1);
                EMA200 = iMA(Symbol(), Period(), 200, 0, MODE_EMA, PRICE_CLOSE, 1);
                SMA65 = iMA(Symbol(), Period(), 65, 0, MODE_SMA, PRICE_CLOSE, 1);
                EMA65 = iMA(Symbol(), Period(), 65, 0, MODE_EMA, PRICE_CLOSE, 1);
                RSI14 = iRSI(Symbol(), Period(), 14, PRICE_CLOSE, 1);
                ATR14 = iCustom(NULL, Period(), "Adaptive_ATR", this.ATRPeriod, 0, 1); 
            }
            
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
      if (openPosition == NULL) return;
      double price;
      if (openPosition.getPositionType() == OP_BUY) price = Bid; else price = Ask;
      if (OrderClose(OrderTicket(), OrderLots(), price, 30, White)) {
          if (OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY) == true) {
             Logger::log("Position closed");
             savePosition(MANUAL_CLOSE);
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
         savePosition(AUTOMATIC_CLOSE);
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
            savePosition(AUTOMATIC_CLOSE);
         }
      }
   }
   
   /*
      Called every time onTick is called. Checks status of positions and
      break even. 
   */
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
   
   /*
      Save position to backtest array of positions.
   */
   void savePosition(CloseType closeType) {
      double oGrossProfit = NormalizeDouble(OrderProfit(), 2);
      double oCommission = NormalizeDouble(OrderCommission(), 2);
      double oSwap = NormalizeDouble(OrderSwap(), 2);
      double oNetProfit = NormalizeDouble(oGrossProfit - oCommission + oSwap, 2);
      openPosition.setPositionClosed(OrderCloseTime(), NormalizeDouble(OrderClosePrice(), Digits), oGrossProfit, oNetProfit, oCommission, oSwap, closeType);
      backtestInfo.savePosition(openPosition);
      openPosition = NULL;
   }
};
