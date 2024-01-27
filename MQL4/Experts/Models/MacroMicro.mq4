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
extern string strategy_name = "MacroMicro-1.0";

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
// Macro Micro Cross
extern int TE_MaPeriod = 20;
extern int TE_MaFilterPass = 1;
extern int TE_MaShift = 0;
extern double TE_Deviation = 0.2;
extern int TE_EnumPrice = 16;
extern ENUM_TIMEFRAMES mTE_tf = PERIOD_H4;
extern int mTE_MaPeriod = 20;
extern int mTE_MaFilterPass = 1;
extern int mTE_MaShift = 0;
extern double mTE_Deviation = 0.2; 
extern int mTE_EnumPrice = 16;

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
   inputJson["TE_MaPeriod"] = TE_MaPeriod;
   inputJson["TE_MaFilterPass"] = TE_MaFilterPass;
   inputJson["TE_MaShift"] = TE_MaShift;
   inputJson["TE_Deviation"] = TE_Deviation;
   inputJson["TE_EnumPrice"] = TE_EnumPrice;
   inputJson["mTE_tf"] = int(mTE_tf);
   inputJson["mTE_MaPeriod"] = mTE_MaPeriod;
   inputJson["mTE_MaFilterPass"] = mTE_MaFilterPass;
   inputJson["mTE_MaShift"] = mTE_MaShift;
   inputJson["mTE_Deviation"] = mTE_Deviation; 
   inputJson["mTE_EnumPrice"] = mTE_EnumPrice;

   riskManager = new RiskManager(risk_per_trade, SL_ratio, TP_ratio, breakeven, 0.9, 0.2, ATR_period);
   backtestInfo = new BacktestInfo(strategy_name, inputJson.Serialize(), export_data);
   positionManager = new PositionManager(riskManager, backtestInfo, customSession, SL_ratio, TP_ratio, ATR_period, risk_per_trade, slippage, breakeven, fixed_sltp);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   positionManager.onDeInit();
   
   double profitFactor = NormalizeDouble(TesterStatistics(STAT_PROFIT_FACTOR), 2);
   if (profitFactor >= 1.3) backtestInfo.exportBacktest();

   delete backtestInfo;
   delete positionManager;
}

void OnTick() {
   static datetime timeCur; datetime timePre = timeCur; timeCur=Time[0];
   bool isNewBar = timeCur != timePre;

   if(isNewBar) {
      backtestInfo.setDate(Time[0]);
      customSession.refresh();

      switch(positionManager.getStatus()) {
         case AVAILABLE_TO_OPEN: {
            OrderAction action = TE_Macro_Micro_Cross(TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_EnumPrice, mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_EnumPrice);
            
            if(action == OA_OPEN_SHORT) {
               positionManager.openOrder(OP_SELL);
            } else if(action == OA_OPEN_LONG) {
               positionManager.openOrder(OP_BUY);
            }

            break;
         }
      }
   }

   
}
