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

string insertModelQuery(string name, string inputs, int period) {
   return StringFormat("INSERT INTO models (name, inputs, period) VALUES ('%s', '%s', %d)", name, inputs, period);
}

string findModelQuery(string name, string inputs, int period) {
   return StringFormat("SELECT id FROM models WHERE name = '%s' AND inputs = '%s' AND period = %d", name, inputs, period);
}

string findBacktestQuery(int backtestLaunchTime) {
   return StringFormat("SELECT id FROM backtests WHERE backtest_launch_time = %d", backtestLaunchTime);
}


string insertPositionQuery(string name, string inputs) {
   return StringFormat("SELECT id FROM models where name = '%s' AND inputs = '%s'", name, inputs);
}

string getCurrentTimeQuery() {
   return "SELECT CAST(strftime('%s', 'now') as INT)";
}

string setBacktestDataQuery(
   int symbolId,
   int modelId,
   double balance,
   double profit,
   double profitFactor, 
   double consecutiveDrawdown,
   double longsWon,
   double shortsWon,
   int dateFrom, 
   int dateTo, 
   int totalTrades, 
   int longTrades, 
   int shortTrades,
   int consecutiveWins,
   int consecutiveLosses,
   int backtestLaunchTime
){    
      string base = "";
      StringAdd(base,"INSERT INTO backtests ");
      StringAdd(base,"(symbol_id, model_id, balance, profit, profit_factor, drawdown, longs_won, shorts_won, date_from, date_to, total_trades,long_trades,short_trades, consecutive_wins, consecutive_losses, backtest_launch_time) ");
      StringAdd(base,StringFormat("VALUES (%d, %d, %f, %f,  %f,  %f,  %f,  %f, %d, %d, %d, %d, %d, %d, %d, %d)", symbolId, modelId, balance, profit, profitFactor, consecutiveDrawdown, longsWon, shortsWon, dateFrom, dateTo, totalTrades, longTrades, shortTrades, consecutiveWins, consecutiveLosses, backtestLaunchTime));
      return base;
      
 }
 
 string setPositionQuery(
      int backtestId,
      int number,
      long openTime,
      long closeTime,
      double gross_profit,
      double net_profit,
      int positionType,
      double balance,
      double lotSize,
      double openPrice,
      double closePrice,
      double slPrice,
      double tpPrice,
      double commission,
      double swap,
      double SMA200,
      double EMA200,
      double SMA65,
      double EMA65,
      double RSI14,
      double ATR14,
      int breakEvenFlag,
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
