#property copyright "Tykee"
#property link      "tykee.eu"
#property version   "1.00"
#property strict

#include <Tykee/main/backtest.mqh>
#include <Tykee/main/positionmanager.mqh>
#include <Tykee/main/riskmanager.mqh>

#include <Tykee/common/utils.mqh>
#include <Tykee/common/enums.mqh>
#include <Tykee/common/logger.mqh>
#include <Tykee/common/position.mqh>
#include <Tykee/common/session.mqh>

#include <Tykee/signals/exit.mqh>
#include <Tykee/signals/entry.mqh>
#include <Tykee/signals/confirmations.mqh>

// Backtest controls
bool print_logs = false; // If true, all logs added via custom logger will be visible in journal
extern bool export_data = true;

// Strategy name - version
extern string strategy_name = "DEWA-1.0";

// Backtest's externals for optimization
extern bool fixed_sltp = false;
extern int slippage = 3;
extern int ATR_period = 14;
extern double SL_ratio = 1.5;
extern double TP_ratio = 3.0;
extern double breakeven = 0.5;
extern double profit_zone = 0.5;
extern double profit_zone_reward = 0.1;
extern double risk_per_trade = 1.0;

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
RiskManager* riskManager;

int OnInit() {
   Logger::isDebug = print_logs;

   customSession = new CustomSession();
   customSession.addMinuteRange(0, 59, OPEN_BOTH); // Min 0, Max 59
   customSession.addHourRange(2, 22, OPEN_BOTH); // Min 0, Max 23
   customSession.addDayOfWeekRange(1, 7, OPEN_BOTH); // Min 1, Max 7
   customSession.addMonthRange(1, 12, OPEN_BOTH); // Min 1, Max 12
   customSession.setPositionLimit(10, PERIOD_D1); // Support only H1, D1 and MN1

   CJAVal inputJson;
   inputJson["SL_RATIO"] = SL_ratio;
   inputJson["TP_RATIO"] = TP_ratio;
   inputJson["FIXED_SLTP"] = fixed_sltp;
   inputJson["SLIPPAGE"] = slippage;
   inputJson["BREAKEVEN"] = breakeven;
   inputJson["PROFIT_ZONE"] = profit_zone;
   inputJson["PROFIT_ZONE_REWARD"] = profit_zone_reward;
   inputJson["BREAKEVEN_WR"] = NormalizeDouble((SL_ratio / (SL_ratio + TP_ratio) * 100), 2);
   inputJson["RISK"] = risk_per_trade;
   inputJson["ATR_period"] = ATR_period;
   inputJson["DEMA_period"] = DEMA_period;
   inputJson["DEMA_filter"] = DEMA_filter;
   inputJson["DEMA_filter_period"] = DEMA_filter_period;
   inputJson["DEMA_enum_price"] = DEMA_enum_price;
   inputJson["DEMA_enum_filter"] = DEMA_enum_filter;
   inputJson["WDH_sensetive"] = WDH_sensetive;
   inputJson["WDH_dead_zone"] = WDH_dead_zone;
   inputJson["WDH_explosion_power"] = WDH_explosion_power;
   inputJson["WDH_trend_power"] = WDH_trend_power;

   riskManager = new RiskManager(risk_per_trade, SL_ratio, TP_ratio, breakeven, 0.9, 0.2, ATR_period);
   backtestInfo = new BacktestInfo(strategy_name, inputJson.Serialize(), export_data);
   positionManager = new PositionManager(riskManager, backtestInfo, customSession, SL_ratio, TP_ratio, ATR_period, risk_per_trade, slippage, breakeven, fixed_sltp);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   positionManager.onDeInit();     
   backtestInfo.exportBacktest();
   delete backtestInfo;
   delete positionManager;
}

void OnTick(){
   static datetime timeCur; datetime timePre = timeCur; timeCur=Time[0];
   bool isNewBar = timeCur != timePre;

   if(isNewBar) {
      backtestInfo.setDate(Time[0]);
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
