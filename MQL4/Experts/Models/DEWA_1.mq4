#property copyright "Tykee"
#property link      "tykee.eu"
#property version   "1.00"
#property strict

#include <Tykee/main/backtest.mqh>
#include <Tykee/main/positionmanager.mqh>

#include <Tykee/common/utils.mqh>
#include <Tykee/common/enums.mqh>
#include <Tykee/common/logger.mqh>
#include <Tykee/common/position.mqh>
#include <Tykee/common/session.mqh>

#include <Tykee/signals/exit.mqh>
#include <Tykee/signals/entry.mqh>
#include <Tykee/signals/confirmations.mqh>

#include <Tykee/database/DB.mqh>

// Backtest controls
bool exportData = true; // If true, backtest data will be exported to DB
bool printLogs = false; // If true, all logs added via custom logger will be visible in journal

// Backtest's externals for optimization
extern double riskPerTrade = 1.0;
extern double SLRatio = 1.5;
extern double TPRatio = 3.0;
extern int ATR_Period = 14;
extern bool fixedSLTP = false;
extern int slippage = 3;
extern double breakEven = 0.5; 

// Strategies externals
// DEMA
extern double DEMA_Period = 26;
extern double DEMA_filter = 0;
extern int DEMA_FilterPeriod = 0;
extern int DEMA_enum_price = 0;
extern int DEMA_enum_filter = 0;
// Waddah
extern int WDH_sensetive = 150;
extern int WDH_deadZone = 30;
extern int WDH_explosionPower = 15;
extern int WDH_trendPower = 15;

BacktestInfo* backtestInfo;
PositionManager* positionManager;
CustomSession* customSession;

int OnInit() {
   Logger::isDebug = printLogs;

   customSession = new CustomSession();
   customSession.addMinuteRange(0, 59, OPEN_BOTH); // Min 0, Max 59
   customSession.addHourRange(2, 22, OPEN_BOTH); // Min 0, Max 23
   customSession.addDayOfWeekRange(1, 7, OPEN_BOTH); // Min 1, Max 7
   customSession.addMonthRange(1, 12, OPEN_BOTH); // Min 1, Max 12
   customSession.setPositionLimit(10, PERIOD_D1); // Support only H1, D1 and MN1

   CJAVal inputJson;
   inputJson["RISK_PER_TRADE"] = riskPerTrade;
   inputJson["SL_RATIO"] = SLRatio;
   inputJson["TP_RATIO"] = TPRatio;
   inputJson["FIXED_SLTP"] = fixedSLTP;
   inputJson["SLIPPAGE"] = slippage;
   inputJson["BREAK_EVEN"] = breakEven;
   inputJson["ATR_Period"] = ATR_Period;
   inputJson["DEMA_Period"] = DEMA_Period;
   inputJson["DEMA_filter"] = DEMA_filter;
   inputJson["DEMA_FilterPeriod"] = DEMA_FilterPeriod;
   inputJson["DEMA_enum_price"] = DEMA_enum_price;
   inputJson["DEMA_enum_filter"] = DEMA_enum_filter;
   inputJson["WDH_sensetive"] = WDH_sensetive;
   inputJson["WDH_deadZone"] = WDH_deadZone;
   inputJson["WDH_explosionPower"] = WDH_explosionPower;
   inputJson["WDH_trendPower"] = WDH_trendPower;

   backtestInfo = new BacktestInfo(__FILE__, inputJson.Serialize(), exportData);
   positionManager = new PositionManager(backtestInfo, customSession, SLRatio, TPRatio, ATR_Period, riskPerTrade, slippage, breakEven, fixedSLTP);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   positionManager.onDeInit();     
   backtestInfo.exportBacktestData();
   delete backtestInfo;
   delete positionManager;
}

void OnTick(){
   datetime tickTime = iTime(Symbol(), Period(), 0);
   backtestInfo.setDate(tickTime);
   customSession.refresh();

   switch(positionManager.getStatus()) {
      case AVAILABLE_TO_OPEN: {
      OrderAction action = DEMA_Simple(DEMA_Period, DEMA_enum_price, DEMA_filter, DEMA_FilterPeriod, DEMA_enum_filter);
      OrderAction confirm = Waddah_Confirmation(WDH_sensetive, WDH_deadZone, WDH_explosionPower, WDH_trendPower);
      
      if(action == OA_OPEN_SHORT && confirm == OA_OPEN_SHORT){
         positionManager.openOrder(OP_SELL);
      } else if(action == OA_OPEN_LONG && confirm == OA_OPEN_LONG) {
         positionManager.openOrder(OP_BUY);
      }
      break;
      }
   }
}
