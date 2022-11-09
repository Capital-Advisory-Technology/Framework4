#include <SQLite3/Statement.mqh>

#include <Tykee/common/position.mqh>
#include <Tykee/common/session.mqh>
#include <Tykee/database/DB.mqh>
#include <Tykee/database/queries.mqh>
#include <Tykee/common/extensions.mqh>
#include <Tykee/http/repository.mqh>

static string entryFunctionList[];
static string exitFunctionList[];
static string confirmFunctionList[];

/*
   BacktestInfo class to store all relevant information about backtest.
   Initialized once in OnInit(). Contains general information and all backtest 
   positions to be exported when DeInit() happens.
*/
class BacktestInfo {

 public:
      BacktestInfo::BacktestInfo(string cModelName, string cModelParams, bool cShouldExportData) {
         this.initialBalance = AccountBalance();
         this.modelName = cModelName;
         this.inputJson = cModelParams;
         this.db = new Database();
         this.symbolId = db.getSymbolId(Symbol());
         this.backtestLaunchTime = db.getDateTime();
         this.shouldExportData = cShouldExportData;
         this.period = Period();
      };
      
      ~BacktestInfo() {
         for (int i = 0; i < ArraySize(positions); i++) {
            delete positions[i];
            delete db;
         }
      }
      
      void setDate(datetime date){
         if (dateFrom == NULL) {
            dateFrom = int(date);
         }
         dateTo = int(date);
      };
      
      void exportBacktestData() {
         if (!shouldExportData) return;
         int backtestDuration = db.getDateTime() - backtestLaunchTime;
        
         doCalculations();
         Logger::log("Model name: " + modelName);
         Logger::log("Params: " + inputJson);
         Logger::log("Profit: " + string(profit));
         Logger::log("Profit factor: " + string(profitFactor));
         Logger::log("Consecutive Drawdown: " + string(consecutiveDrawdown));
         Logger::log("Long wons: " + string(longsWon));
         Logger::log("Short won: " + string(shortsWon));
         Logger::log("Initial balance: " + string(initialBalance));
         Logger::log("Date from: " + string(dateFrom));
         Logger::log("Date to: " + string(dateTo));
         Logger::log("Total trades: " + string(totalTrades));
         Logger::log("Long trades: " + string(longTrades));
         Logger::log("Short trades: " + string(shortTrades));
         Logger::log("Consecutive wins: " + string(consecutiveWins));
         Logger::log("Consecutive losses: " + string(consecutiveLosses));
         
         
         // if (profitFactor <= 1.3) return;
         
         int strategyId = db.getStrategyId(modelName);
         string backtestSql = setBacktestDataQuery(
             symbolId, strategyId,
             period, initialBalance,
             profit, profitFactor,
             consecutiveDrawdown,longsWon, 
             shortsWon,dateFrom,
             dateTo,totalTrades,
             longTrades, shortTrades,
             consecutiveWins, consecutiveLosses,
             backtestLaunchTime, backtestDuration,
             customSession.toJson(), inputJson,
             stringListToJson(entryFunctionList), stringListToJson(exitFunctionList),
             stringListToJson(confirmFunctionList), AccountCurrency()
         );
        
         db.insertData(backtestSql);
         int backtestId = db.findBacktestId(backtestLaunchTime);
         SendResquest("POST", "/upload/backtest", toJson(backtestDuration));
         
         for (int i = 0; i < ArraySize(positions); i++) {
            db.insertData(positions[i].getSql(backtestId));
         }
      }
      
      void savePosition(Position* position) {
         ArrayResize(positions, ArraySize(positions) + 1); 
         positions[ArraySize(positions) - 1] = position; 
      }
      
      bool getShouldExportData() {
         return shouldExportData;
      }
      
      void setCustomSessionObject(CustomSession* cCustomSession) {
         this.customSession = cCustomSession;
      }

   private:
      bool shouldExportData;
      string modelName;
      string inputJson; 
      double profit; 
      double profitFactor; 
      double consecutiveDrawdown;
      double longsWon;
      double shortsWon; 
      double initialBalance;
      int dateFrom; 
      int dateTo;
      int backtestLaunchTime;
      int totalTrades; 
      int longTrades; 
      int shortTrades; 
      int consecutiveWins; 
      int consecutiveLosses;
      int symbolId;
      int period;
      Position* positions[];
      Database* db;
      CustomSession* customSession;
      
      void doCalculations() {
          int positionAmount = ArraySize(positions);
          totalTrades = positionAmount;
          profit = NormalizeDouble(((AccountBalance() - initialBalance) / initialBalance) * 100, 2);
          setConsecutiveStats(positionAmount);
          setTradeOveralls(positionAmount);
      }
      
      void setConsecutiveStats(int positionAmount) {
         int tempConsecutiveLoses = 0;
         int tempConsecutiveWins = 0;
         double tempConsecutiveDrawdown = 0;
         double grossProfit = 0;
         double grossLoss = 0;
         
         for (int i = 0; i < positionAmount; i++) {
            Position* position = positions[i];
            
            if (position.getNetProfit() > 0) {
               tempConsecutiveWins++;
               
               if (tempConsecutiveWins > consecutiveWins){
                consecutiveWins = tempConsecutiveWins;
               }
               
               grossProfit += position.getNetProfit();
               tempConsecutiveLoses = 0;
               tempConsecutiveDrawdown = 0;
            } else {
               tempConsecutiveLoses++;
               tempConsecutiveDrawdown += position.getNetProfit();
               
               if (tempConsecutiveDrawdown < consecutiveDrawdown){
                consecutiveDrawdown = tempConsecutiveDrawdown;
               }
               
               if (tempConsecutiveLoses > consecutiveLosses) {
                consecutiveLosses = tempConsecutiveLoses;
               } 
               
               consecutiveDrawdown = NormalizeDouble((consecutiveDrawdown / initialBalance) * 100, 2);
               grossLoss += position.getNetProfit();     
               tempConsecutiveWins = 0;
            }
         }
         
         profitFactor = NormalizeDouble(MathAbs(grossProfit / grossLoss), 2);
      }
      
      string toJson(int backtestDuration) {
         CJAVal json;
         CJAVal backtestObject;
         backtestObject["symbol"] = Symbol();
         backtestObject["period"] = period;
         backtestObject["balance"] = initialBalance;
         backtestObject["profit"] = profit;
         backtestObject["profit_factor"] = profitFactor;
         backtestObject["drawdown"] = consecutiveDrawdown;
         backtestObject["longs_won"] = longsWon;
         backtestObject["shorts_won"] = shortsWon;
         backtestObject["date_from"] = dateFrom;
         backtestObject["date_to"] = dateTo;
         backtestObject["total_trades"] = totalTrades;
         backtestObject["long_trades"] = longTrades;
         backtestObject["short_trades"] = shortTrades;
         backtestObject["consecutive_wins"] = consecutiveWins;
         backtestObject["consecutive_losses"] = consecutiveLosses;
         backtestObject["backtest_launch_time"] = backtestLaunchTime;
         backtestObject["backtest_duration"] = backtestDuration;
         backtestObject["session_limits"] = customSession.toJson();
         backtestObject["inputs"] = inputJson;
         backtestObject["entry_list"] = stringListToJson(entryFunctionList);
         backtestObject["exit_list"] = stringListToJson(exitFunctionList);
         backtestObject["confirmation_list"] = stringListToJson(confirmFunctionList);
         backtestObject["account_currency"] = AccountCurrency();
         CJAVal positionObject;
         for (int i = 0; i < 5; i++) {
            positionObject.Add(positions[i].toJson());
         }
         
         json["backtest_info"] = backtestObject;
         json["strategy_name"] = modelName;
         json["positions"] = positionObject;
         Print(json.Serialize());
         return json.Serialize(); 
      }

      void setTradeOveralls(int positionAmount) {
         int tempLongsWon = 0;
         int tempShortsWon = 0;
         
         for (int i = 0; i < positionAmount; i++) {
            Position* position = positions[i];
            double positionProfit = position.getNetProfit();
           
            if (position.getPositionType() == OP_BUY) {
               if (positionProfit > 0) tempLongsWon++;
               longTrades++;
            } else {
               if (positionProfit > 0) tempShortsWon++;
               shortTrades++;
            }
         }
         longsWon = NormalizeDouble(double(tempLongsWon) / longTrades * 100, 2);
         shortsWon = NormalizeDouble(double(tempShortsWon) / shortTrades * 100, 2);
      }
};

 void addToEntryFunctionList(string name) {
   bool shouldAdd = true;   
   for (int i = 0; i < ArraySize(entryFunctionList); i++) {
      if (entryFunctionList[i] == name) return;
   }

   ArrayResize(entryFunctionList, ArraySize(entryFunctionList) + 1); 
   entryFunctionList[ArraySize(entryFunctionList) - 1] = name;
}

 void addToExitFunctionList(string name) {
   bool shouldAdd = true;   
   for (int i = 0; i < ArraySize(exitFunctionList); i++) {
      if (exitFunctionList[i] == name) return;
   }
   ArrayResize(exitFunctionList, ArraySize(exitFunctionList) + 1); 
   exitFunctionList[ArraySize(exitFunctionList) - 1] = name;
}

 void addToConfirmationFunctionList(string name) {
   bool shouldAdd = true;   
   for (int i = 0; i < ArraySize(confirmFunctionList); i++) {
      if (confirmFunctionList[i] == name) return;
   }
   ArrayResize(confirmFunctionList, ArraySize(confirmFunctionList) + 1); 
   confirmFunctionList[ArraySize(confirmFunctionList) - 1] = name;
}
