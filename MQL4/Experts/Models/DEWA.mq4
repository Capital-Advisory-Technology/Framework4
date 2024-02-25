#include <Tykee/signals/exit.mqh>
#include <Tykee/signals/confirmations.mqh>

// Strategy name - version
extern string strategy_name = "DEWA-1.0";

// Backtest's externals for optimization
extern bool fixed_sltp = false;
extern int slippage = 3;
extern int ATR_period = 14;
extern double SL_ratio = 1.5;
extern double TP_ratio = 3.0;
extern double breakeven = 0.5;
extern double profit_zone = 0.9;
extern double profit_zone_reward = 0.2;
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
   positionManager = new PositionManager(riskManager, customSession, SL_ratio, TP_ratio, ATR_period, risk_per_trade, slippage, breakeven, fixed_sltp);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { 
   delete positionManager;
}

void OnTick() {
   static datetime timeCur; datetime timePre = timeCur; timeCur=Time[0];
   bool isNewBar = timeCur != timePre;

   if(!isNewBar) return;
   if(positionManager.getStatus() != AVAILABLE_TO_OPEN) return;

   customSession.refresh();

   OrderAction action = DEMA_Simple(DEMA_period,
                                    DEMA_enum_price,
                                    DEMA_filter,
                                    DEMA_filter_period,
                                    DEMA_enum_filter);

   OrderAction confirm = Waddah_Confirmation(WDH_sensetive,
                                             WDH_dead_zone,
                                             WDH_explosion_power,
                                             WDH_trend_power);
   
   if(action == OA_OPEN_SHORT && confirm == OA_OPEN_SHORT) {
      positionManager.openOrder(OP_SELL);
   } else if(action == OA_OPEN_LONG && confirm == OA_OPEN_LONG) {
      positionManager.openOrder(OP_BUY);
   }
}

void InitLog() {
   Logger::log("Symbol: " + Symbol());
   Logger::log("Point: " + string(_Point));
   Logger::log("Strategy name: " + strategy_name);
}