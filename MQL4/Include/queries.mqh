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

string insertModelQuery(string name, string inputs) {
   return StringFormat("INSERT INTO models (name, inputs) VALUES ('%s', '%s')", name, inputs);
}

string findModelQuery(string name, string inputs) {
   return StringFormat("SELECT id FROM models where name = '%s' AND inputs = '%s'", name, inputs);
}

string insertPositionQuery(string name, string inputs) {
   return StringFormat("SELECT id FROM models where name = '%s' AND inputs = '%s'", name, inputs);
}

string setBacktestDataQuery(
   int symbolId,
   int modelId,
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
   int consecutiveLosses
){
     return StringFormat(
     "INSERT INTO backtests (symbol_id, model_id, profit, profit_factor, drawdown, longs_won, shorts_won, date_from, date_to, total_trades, long_trades, short_trades, consecutive_wins, consecutive_losses) VALUES (%d, %d, %f,  %f,  %f,  %f,  %f, %d, %d, %d, %d, %d, %d, %d)", symbolId, modelId, profit, profitFactor, consecutiveDrawdown, longsWon, shortsWon, dateFrom, dateTo, totalTrades, longTrades, shortTrades, consecutiveWins, consecutiveLosses);
}