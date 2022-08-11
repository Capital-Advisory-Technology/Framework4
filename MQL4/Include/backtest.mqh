
#include <position.mqh>
#include <SQLite3/Statement.mqh>
#include <DB.mqh>
#include <queries.mqh>

class BacktestInfo {

 public: 
      BacktestInfo::BacktestInfo(string cModelName, string cModelParams) {
         this.initialBalance = AccountBalance();
         this.modelName = cModelName;
         this.modelParamsJson = cModelParams;
      };
      
      ~BacktestInfo() {
         for (int i = 0; i < ArraySize(positions); i++) {
            delete positions[i];
         }
      }
      
      void setDate(datetime date){
         if (dateFrom == NULL) {
            dateFrom = int(date);
         }
         dateTo = int(date);
      };
      
      void exportBacktestData() {
         doCalculations();
         Print("Model name: " + modelName);
         Print("Params: " + modelParamsJson);
         Print("Profit: " + string(profit));
         Print("Profit factor: " + string(profitFactor));
         Print("Consecutive Drawdown: " + string(consecutiveDrawdown));
         Print("Long wons: " + string(longsWon));
         Print("Short won: " + string(shortsWon));
         Print("Initial balance: " + string(initialBalance));
         Print("Date from: " + string(dateFrom));
         Print("Date to: " + string(dateTo));
         Print("Total trades: " + string(totalTrades));
         Print("Long trades: " + string(longTrades));
         Print("Short trades: " + string(shortTrades));
         Print("Consecutive wins: " + string(consecutiveWins));
         Print("Consecutive losses: " + string(consecutiveLosses));
         
         Database* db = new Database();
         
         int modelId = db.getModelId(modelName, modelParamsJson);
         
         string backtestSql = setBacktestDataQuery(0, modelId, profit, profitFactor, consecutiveDrawdown, longsWon, shortsWon, dateFrom, dateTo,totalTrades, longTrades, shortTrades, consecutiveWins, consecutiveLosses);
         Print(backtestSql);
         db.insertData(backtestSql);
         Print("MODEL ID " + modelId);
      }
      
      void savePosition(Position* position) {
         ArrayResize(positions, ArraySize(positions) + 1); 
         positions[ArraySize(positions) - 1] = position; 
      }

   private:
      string modelName;
      string modelParamsJson; 
      double profit; 
      double profitFactor; 
      double consecutiveDrawdown;
      double longsWon;
      double shortsWon; 
      double initialBalance;
      int dateFrom; 
      int dateTo; 
      int totalTrades; 
      int longTrades; 
      int shortTrades; 
      int consecutiveWins; 
      int consecutiveLosses; 
      Position* positions[];
      
      void doCalculations() {
          int positionAmount = ArraySize(positions);
          totalTrades = positionAmount;
          profit = (AccountBalance() - initialBalance) / initialBalance;
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
            
            if (position.getProfit() > 0) {
               tempConsecutiveWins++;
               
               if (tempConsecutiveWins > consecutiveWins){
                consecutiveWins = tempConsecutiveWins;
               }
               
               grossProfit += position.getProfit();
               tempConsecutiveLoses = 0;
               tempConsecutiveDrawdown = 0;
            } else {
               tempConsecutiveLoses++;
               tempConsecutiveDrawdown += position.getProfit();
               
               if (tempConsecutiveDrawdown < consecutiveDrawdown){
                consecutiveDrawdown = tempConsecutiveDrawdown;
               }
               
               if (tempConsecutiveLoses > consecutiveLosses) {
                consecutiveLosses = tempConsecutiveLoses;
               } 
               
               grossLoss += position.getProfit();     
               tempConsecutiveWins = 0;
            }
         }
         
         profitFactor = MathAbs(grossProfit / grossLoss);
      }
      
      void setTradeOveralls(int positionAmount) {
         int tempLongsWon = 0;
         int tempShortsWon = 0;
         
         for (int i = 0; i < positionAmount; i++) {
            Position* position = positions[i];
            double positionProfit = position.getProfit();
           
            if (position.getPositionType() == OP_BUY) {
               if (positionProfit > 0) tempLongsWon++;
               longTrades++;
            } else {
               if (positionProfit > 0) tempShortsWon++;
               shortTrades++;
            }
         }
         longsWon = double(tempLongsWon) / longTrades;
         shortsWon = double(tempShortsWon) / shortTrades;
      }
};
