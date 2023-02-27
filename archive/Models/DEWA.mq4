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
bool export_data = true; // If true, backtest data will be exported to DB
bool print_logs = false; // If true, all logs added via custom logger will be visible in journal

// Strategy name - version
extern string strategy_name = "DEWA-1.0";

// Backtest's externals for optimization
extern double risk_per_trade = 1.0;
extern double sl_ratio = 1.5;
extern double tp_ratio = 3.0;
extern int atr_period = 14;
extern bool fixed_sltp = false;
extern int slippage = 3;
extern double break_even = 0.5; 

// Strategies externals
// DEMA
extern double DEMA_period = 26;
extern double DEMA_filter = 0;
extern int DEMA_filter_period = 0;
extern int DEMA_enum_price = 0;
extern int DEMA_enum_filter = 0;
// Waddah
extern int WDH_sensetive = 150;
extern int WDH_dead_zone = 30;
extern int WDH_explosion_power = 15;
extern int WDH_trend_power = 15;

BacktestInfo* backtestInfo;
PositionManager* positionManager;
CustomSession* customSession;

int OnInit() {
   Logger::isDebug = print_logs;

   customSession = new CustomSession();
   customSession.addMinuteRange(0, 59, OPEN_BOTH); // Min 0, Max 59
   customSession.addHourRange(2, 22, OPEN_BOTH); // Min 0, Max 23
   customSession.addDayOfWeekRange(1, 7, OPEN_BOTH); // Min 1, Max 7
   customSession.addMonthRange(1, 12, OPEN_BOTH); // Min 1, Max 12
   customSession.setPositionLimit(10, PERIOD_D1); // Support only H1, D1 and MN1

   CJAVal inputJson;
   inputJson["RISK_PER_TRADE"] = risk_per_trade;
   inputJson["SL_RATIO"] = sl_ratio;
   inputJson["TP_RATIO"] = tp_ratio;
   inputJson["FIXED_SLTP"] = fixed_sltp;
   inputJson["SLIPPAGE"] = slippage;
   inputJson["BREAK_EVEN"] = break_even;
   inputJson["atr_period"] = atr_period;
   inputJson["DEMA_period"] = DEMA_period;
   inputJson["DEMA_filter"] = DEMA_filter;
   inputJson["DEMA_filter_period"] = DEMA_filter_period;
   inputJson["DEMA_enum_price"] = DEMA_enum_price;
   inputJson["DEMA_enum_filter"] = DEMA_enum_filter;
   inputJson["WDH_sensetive"] = WDH_sensetive;
   inputJson["WDH_dead_zone"] = WDH_dead_zone;
   inputJson["WDH_explosion_power"] = WDH_explosion_power;
   inputJson["WDH_trend_power"] = WDH_trend_power;

   backtestInfo = new BacktestInfo(strategy_name, inputJson.Serialize(), export_data);
   positionManager = new PositionManager(backtestInfo, customSession, sl_ratio, tp_ratio, atr_period, risk_per_trade, slippage, break_even, fixed_sltp);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   positionManager.onDeInit();     
   backtestInfo.export_data();
   delete backtestInfo;
   delete positionManager;
}

void OnTick(){
   static datetime timeCur; datetime timePre = timeCur; timeCur=Time[0];
   bool isNewBar = timeCur != timePre;

   if(isNewBar) {
      datetime tickTime = iTime(Symbol(), Period(), 0);
      backtestInfo.setDate(tickTime);
      customSession.refresh();

      switch(positionManager.getStatus()) {
         case AVAILABLE_TO_OPEN: {
         OrderAction action = DEMA_Simple(DEMA_period, DEMA_enum_price, DEMA_filter, DEMA_filter_period, DEMA_enum_filter);
         OrderAction confirm = Waddah_Confirmation(WDH_sensetive, WDH_dead_zone, WDH_explosion_power, WDH_trend_power);
         
         if(action == OA_OPEN_SHORT && confirm == OA_OPEN_SHORT){
            positionManager.openOrder(OP_SELL);
         } else if(action == OA_OPEN_LONG && confirm == OA_OPEN_LONG) {
            positionManager.openOrder(OP_BUY);
         }
         break;
         }
      }
   }

   
}
