#include <CAT/signals/confirmations.mqh>
#include <CAT/signals/exit.mqh>
#include <CAT/common/exporter.mqh>

// Backtest's externals for optimization
input string BACKTEST_EXTERNALS = "";
extern string strategy_name = "unnamed";
extern int slippage = 3;
extern double exportPFThreshold = 0;

input string RISK_EXTERNALS = "";
extern double max_open_risk = 2.0;
extern int max_open_trades = 2;
extern int ATR_period = 14; 
extern double SL_ratio = 1.5;
extern double TP_ratio = 4;

input string PROFIT_EXTERNALS = "";
extern double breakeven = 0.5;
extern double profit_zone = 0.7;
extern double profit_zone_reward = 0.2;

input string SESSION_EXTERNALS = "";
extern int hour_limit_start = 8;
extern int hour_limit_end = 21;

// Strategies externals
input string STRATEGIES_EXTERNALS = "";

input string DEMA_EXTERNALS = "";
extern double DEMA_period = 26;
extern double DEMA_filter = 0;
extern int DEMA_filter_period = 0;
extern int DEMA_enum_price = 0;
extern int DEMA_enum_filter = 0;

input string TE_EXTERNALS = "";
extern ENUM_TIMEFRAMES TE_timeframe = PERIOD_H4;
extern int TE_period = 8;
extern int TE_filterPass = 8;
extern int TE_enum_price = 30;

BacktestExporter* backtestExporter;
PositionManager* positionManager;
CustomSession* customSession;
RiskManager* riskManager;

int OnInit() {
    Logger::log("Strategy name: " + strategy_name + " Symbol: " + Symbol() + " Point: " + string(_Point));
    
    customSession = new CustomSession();
    customSession.addMinuteRange(0, 59, OPEN_BOTH);                           // Min 0, Max 59
    customSession.addHourRange(hour_limit_start, hour_limit_end, OPEN_BOTH);  // Min 0, Max 23
    customSession.addDayOfWeekRange(1, 7, OPEN_BOTH);                         // Min 1, Max 7
    customSession.addMonthRange(1, 12, OPEN_BOTH);                            // Min 1, Max 12
    customSession.setPositionLimit(10, PERIOD_D1);                            // Support only H1, D1 and MN1

    backtestExporter = new BacktestExporter();
    
    riskManager = new RiskManager(max_open_risk, max_open_trades, SL_ratio, TP_ratio,
                                  breakeven, profit_zone, profit_zone_reward, ATR_period);

    positionManager = new PositionManager(riskManager, customSession, slippage, max_open_trades);

    return (INIT_SUCCEEDED);
}

void OnTick() {
    static datetime timeCur;
    datetime timePre = timeCur;
    timeCur = Time[0];
    bool isNewBar = timeCur != timePre;
    if (!isNewBar) return;
    Logger::log("New bar: " + string(timeCur));

    // not working quite yet...
    // if (positionManager.rolloverDeals() != true) return;
    if (positionManager.getStatus() != AVAILABLE_TO_OPEN) return;

    customSession.refresh();

    OrderAction dema_signal = DEMA_Simple(DEMA_period,DEMA_enum_price,DEMA_filter,
                                          DEMA_filter_period,DEMA_enum_filter);

    OrderAction te_confirm = TE_Confirmation(TE_timeframe, TE_period, TE_filterPass, 0, 0.2, TE_enum_price);

    if (dema_signal && te_confirm == OA_OPEN_SHORT) { positionManager.openOrder(OP_SELL);
    
    } else if (dema_signal && te_confirm == OA_OPEN_LONG) { positionManager.openOrder(OP_BUY);
    
    } else Logger::log("OnTick: No signal");
    
}

void OnDeinit(const int reason) {
    if ((IsOptimization() || IsTesting()) && TesterStatistics(STAT_PROFIT_FACTOR) >= exportPFThreshold) {
        CJAVal inputJson;
    
        inputJson["strategy_name"] = strategy_name;
        inputJson["slippage"] = slippage;

        inputJson["max_open_risk"] = max_open_risk;
        inputJson["max_open_trades"] = max_open_trades;
        inputJson["ATR_period"] = ATR_period;
        inputJson["SL_ratio"] = SL_ratio;
        inputJson["TP_ratio"] = TP_ratio;

        inputJson["breakeven"] = breakeven;
        inputJson["profit_zone"] = profit_zone;
        inputJson["profit_zone_reward"] = profit_zone_reward;

        inputJson["hour_limit_start"] = hour_limit_start;
        inputJson["hour_limit_end"] = hour_limit_end;

        inputJson["DEMA_period"] = DEMA_period;
        inputJson["DEMA_filter"] = DEMA_filter;
        inputJson["DEMA_filter_period"] = DEMA_filter_period;
        inputJson["DEMA_enum_price"] = DEMA_enum_price;
        inputJson["DEMA_enum_filter"] = DEMA_enum_filter;

        inputJson["TE_timeframe"] = (int)TE_timeframe;
        inputJson["TE_period"] = TE_period;
        inputJson["TE_filterPass"] = TE_filterPass;
        inputJson["TE_enum_price"] = TE_enum_price;

        backtestExporter.exportBacktest(strategy_name, inputJson.Serialize(), customSession.toString());
    }

    delete backtestExporter;
    delete positionManager;
}