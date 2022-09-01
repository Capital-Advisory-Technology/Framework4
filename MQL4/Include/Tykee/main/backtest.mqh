#include <SQLite3/Statement.mqh>

#include <Tykee/common/position.mqh>
#include <Tykee/common/session.mqh>
#include <Tykee/database/DB.mqh>
#include <Tykee/database/queries.mqh>

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
             customSession.toJson(), inputJson
         );
         
         db.insertData(backtestSql);
         int backtestId = db.findBacktestId(backtestLaunchTime);
         
         for (int i = 0; i < ArraySize(positions); i++) {
            positions[i].exportToDatabase(db, backtestId);
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
         longsWon = NormalizeDouble(double(tempLongsWon) / longTrades, 2);
         shortsWon = NormalizeDouble(double(tempShortsWon) / shortTrades, 2);
      }
};
