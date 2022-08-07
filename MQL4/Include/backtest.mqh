
#include <position.mqh>

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
         Print("Drawdown: " + string(drawdown));
         Print("Long wons: " + string(longsWon));
         Print("Short won: " + string(shortsWon));
         Print("Initial balance: " + string(initialBalance));
         Print("Date from: " + string(dateFrom));
         Print("Date to: " + string(dateTo));
         Print("Total trades: " + string(totalTrades));
         Print("Long trades: " + string(longTrades));
         Print("Short trades: " + string(shortTrades));
         Print("Consecutive wins: " + string(consecutiveWins));
         Print("Consecutive loses: " + string(consecutiveLoses));
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
      double drawdown;
      double longsWon;
      double shortsWon; 
      double initialBalance;
      int dateFrom; 
      int dateTo; 
      int totalTrades; 
      int longTrades; 
      int shortTrades; 
      int consecutiveWins; 
      int consecutiveLoses; 
      Position* positions[];
      
      void doCalculations() {
          int positionAmount = ArraySize(positions);
          totalTrades = positionAmount;
          
          profit = (AccountBalance() - initialBalance) / initialBalance;
          
          setConsecutiveStats(positionAmount);
          setTradeOveralls(positionAmount);
          setMaxDrawDown(positionAmount);
      }
      
      void setConsecutiveStats(int positionAmount) {
         int tempConsecutiveLoses = 0;
         int tempConsecutiveWins = 0;
         double grossProfit = 0;
         double grossLoss = 0;
         
         for (int i = 0; i < positionAmount; i++) {
            Position* position = positions[i];
            if (position.getProfit() > 0) {
               grossProfit += position.getProfit();
               tempConsecutiveWins++;
               if (tempConsecutiveWins > consecutiveWins) consecutiveWins = tempConsecutiveWins;
               tempConsecutiveLoses = 0;
            } else {
               tempConsecutiveLoses++;
               if (tempConsecutiveLoses > consecutiveLoses) consecutiveLoses = tempConsecutiveLoses;
               tempConsecutiveWins = 0;
               grossLoss += position.getProfit();
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
            if (position.getPositionType() == 0) {
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
      
      void setMaxDrawDown(int positionAmount) {
         int peakValueIndex = 0;
         for (int i = 0; i < positionAmount; i++) {
            if (positions[i].getBalance() > positions[peakValueIndex].getBalance()) {
               peakValueIndex = i;
            }
         }
         
         int lowestValueAfterPeakIndex = peakValueIndex + 1;
         for (int j = peakValueIndex + 1; j < positionAmount; j++) {
            if (positions[j].getBalance() < positions[lowestValueAfterPeakIndex].getBalance()) {
               lowestValueAfterPeakIndex = j;
            }
         }
         
         double lowestValue = positions[lowestValueAfterPeakIndex].getBalance();
         double highestValue = positions[peakValueIndex].getBalance();
         drawdown = double((lowestValue - highestValue) / highestValue * 100);
      }
};
