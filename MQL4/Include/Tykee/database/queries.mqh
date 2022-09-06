//+------------------------------------------------------------------+
//|                                                      queries.mqh |
//|                                                            Tykee |
//|                                              http://www.tykee.io |
//+------------------------------------------------------------------+
#property copyright "Tykee"
#property link      "http://www.tykee.io"
#property strict


string getSymbolIdQuery(string symbol) {
   return StringFormat("select id, name from symbols where name = '%s';", symbol);
}

string insertStrategyQuery(string name) {
   return StringFormat("INSERT INTO strategies (name) VALUES ('%s')", name);
}

string findStrategyQuery(string name) {
   return StringFormat("SELECT id FROM strategies WHERE name = '%s'", name);
}

string findBacktestQuery(int backtestLaunchTime) {
   return StringFormat("SELECT id FROM backtests WHERE backtest_launch_time = %d", backtestLaunchTime);
}

string getCurrentTimeQuery() {
   return "SELECT CAST(strftime('%s', 'now') as INT)";
}

string setBacktestDataQuery(
   int symbolId, int strategyId,
   int period, double balance,
   double profit, double profitFactor, 
   double consecutiveDrawdown, double longsWon,
   double shortsWon, int dateFrom, 
   int dateTo, int totalTrades, 
   int longTrades, int shortTrades,
   int consecutiveWins, int consecutiveLosses,
   int backtestLaunchTime, int backtestDuration,
   string customSessionJson, string inputs,
   string entryFunctionList, string exitFunctionList,
   string confirmationFunctionList, string currency
){
      string base = "";
      StringAdd(base,"INSERT INTO backtests ");
      StringAdd(base,"(symbol_id, strategy_id, period, balance, profit, profit_factor, drawdown, longs_won, shorts_won, date_from, date_to, total_trades,long_trades,short_trades, consecutive_wins, consecutive_losses, backtest_launch_time, backtest_duration, session_limits, inputs, entry_list, exit_list, confirmation_list, account_currency) ");
      StringAdd(base,StringFormat("VALUES (%d, %d, %d, %f, %f,  %f,  %f,  %f,  %f, %d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s', '%s')", symbolId, strategyId, period, balance, profit, profitFactor, consecutiveDrawdown, longsWon, shortsWon, dateFrom, dateTo, totalTrades, longTrades, shortTrades, consecutiveWins, consecutiveLosses, backtestLaunchTime, backtestDuration, customSessionJson, inputs, entryFunctionList, exitFunctionList, confirmationFunctionList, currency));
      return base;
 }
 
 string setPositionQuery(
      int backtestId, int number,
      long openTime, long closeTime,
      double gross_profit, double net_profit,
      int positionType, double balance,
      double lotSize, double openPrice,
      double closePrice, double slPrice,
      double tpPrice, double commission,
      double swap, double SMA200,
      double EMA200, double SMA65,
      double EMA65, double RSI14,
      double ATR14, int breakEvenFlag,
      int closeType
){    
      string base = "";
      StringAdd(base,"INSERT INTO positions ");
      StringAdd(base,"(backtest_id, order_number, open_time, close_time, gross_profit, net_profit, position_type, lot_size, open_price, close_price, sl_price, tp_price, commission, swap, SMA_200, EMA_200, SMA_65, EMA_65, RSI_14, ATR_14, breakeven_flag, close_type) ");
      StringAdd(
         base,
         StringFormat(
            "VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f ,%f, %f, %f, %f, %d, %d)",
            backtestId, number, openTime, closeTime, gross_profit, net_profit, positionType, lotSize, openPrice, closePrice, slPrice, tpPrice, commission, swap, SMA200, EMA200, SMA65, EMA65, RSI14, ATR14, breakEvenFlag, closeType
         )
      );
      return base; 
 }
