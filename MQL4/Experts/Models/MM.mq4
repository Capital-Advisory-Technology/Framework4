#include <CAT/signals/exit.mqh>
#include <CAT/signals/confirmations.mqh>

// Strategy name - version
extern string strategy_name = "MM-1.0";

// Backtest's externals for optimization
extern bool fixed_sltp = false;
extern int slippage = 3;
extern int max_open_positions = 1;
extern int ATR_period = 14;
extern double SL_ratio = 3.0;
extern double TP_ratio = 1.0;
extern double breakeven = 0.5;
extern double profit_zone = 0.9;
extern double profit_zone_reward = 0.2;
extern double risk_per_trade = 1.0;

// Strategies externals
// Macro Micro Cross
extern int TE_MaPeriod = 36;
extern int TE_MaFilterPass = 1;
extern int TE_MaShift = 0;
extern double TE_Deviation = 0.2;
extern int TE_EnumPrice = 16;
extern ENUM_TIMEFRAMES mTE_tf = PERIOD_D1;
extern int mTE_MaPeriod = 18;
extern int mTE_MaFilterPass = 1;
extern int mTE_MaShift = 0;
extern double mTE_Deviation = 0.2; 
extern int mTE_EnumPrice = 16;

PositionManager* positionManager;
CustomSession* customSession;
RiskManager* riskManager;

int OnInit() {
   InitLog();

   customSession = new CustomSession();
   customSession.addMinuteRange(0, 59, OPEN_BOTH); // Min 0, Max 59
   customSession.addHourRange(2, 22, OPEN_BOTH); // Min 0, Max 23
   customSession.addDayOfWeekRange(1, 7, OPEN_BOTH); // Min 1, Max 7
   customSession.addMonthRange(1, 12, OPEN_BOTH); // Min 1, Max 12
   customSession.setPositionLimit(10, PERIOD_D1); // Support only H1, D1 and MN1

   riskManager = new RiskManager(risk_per_trade, SL_ratio, TP_ratio, breakeven, profit_zone, profit_zone_reward, ATR_period);
   positionManager = new PositionManager(riskManager, customSession, SL_ratio, TP_ratio, ATR_period, risk_per_trade, slippage, breakeven, fixed_sltp, max_open_positions);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   delete positionManager;
}

void OnTick() {
   static datetime timeCur; datetime timePre = timeCur; timeCur=Time[0];
   bool isNewBar = timeCur != timePre;
   
   if(!isNewBar) return;
   Logger::log("New bar: " + string(timeCur));
   
   if(positionManager.getStatus() != AVAILABLE_TO_OPEN) return;

   customSession.refresh();

   OrderAction action = TE_Macro_Micro_Cross(TE_MaPeriod, TE_MaFilterPass, TE_MaShift, TE_Deviation, TE_EnumPrice, mTE_tf, mTE_MaPeriod, mTE_MaFilterPass, mTE_MaShift, mTE_Deviation, mTE_EnumPrice);

   Logger::log("OnTick: Action: " + string(action));
   if(action == OA_OPEN_SHORT) {
      Logger::log("OnTick: Open short");
      positionManager.openOrder(OP_SELL);
   } else if(action == OA_OPEN_LONG) {
      Logger::log("OnTick: Open long");
      positionManager.openOrder(OP_BUY);
   } else {
      Logger::log("OnTick: No signal");
   }
}

void InitLog() {
   Logger::log("Strategy name: " + strategy_name + " Symbol: " + Symbol() + " Point: " + string(_Point));
}