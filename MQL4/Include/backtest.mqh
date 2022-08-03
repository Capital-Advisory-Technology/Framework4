
#include <position.mqh>

const string DATE_FORMAT = "";

class BacktestInfo {

   private:
      string modelName;
      string modelParamsJson; 
      double profit; 
      double profit_factor; 
      double drawdown; // maks papisiens
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
          profit = AccountBalance() - initialBalance;
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
               if (++tempConsecutiveWins > consecutiveWins) consecutiveWins = tempConsecutiveWins;
               tempConsecutiveLoses = 0;
               grossProfit += position.getProfit();
            } else {
               if (++tempConsecutiveLoses > consecutiveLoses) consecutiveLoses = tempConsecutiveLoses;
               tempConsecutiveWins = 0;
               grossLoss += position.getProfit();
            }
         }
         
        
         profit_factor = MathAbs(grossProfit / grossLoss);
         consecutiveWins = tempConsecutiveWins;
         consecutiveLoses = tempConsecutiveLoses;
      }
      
      void setTradeOveralls(int positionAmount) {
         int tempLongsWon = 0;
         int tempShortsWon = 0;
         
         for (int i = 0; i < positionAmount; i++) {
            Position* position = positions[i];
            
            double positionProfit = position.getProfit();
            Print("POSITION PROFIT " + positionProfit);
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
         
         for (int i = peakValueIndex + 1; i < positionAmount; i++) {
            if (positions[i].getBalance() < positions[lowestValueAfterPeakIndex].getBalance()) {
               lowestValueAfterPeakIndex = i;
            }
         }
         
         double lowestValue = positions[lowestValueAfterPeakIndex].getBalance();
         double highestValue = positions[peakValueIndex].getBalance();
         
         Print(lowestValue + " AHSBDLAKSJD " + highestValue);
         drawdown = double((lowestValue - highestValue) / highestValue * 100);
      }
        
      
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
         Print("Profit: " + double(profit));
         Print("Profit factor: " + double(profit_factor));
         Print("Drawdown: " + double(drawdown));
         Print("Long wons: " + double(longsWon));
         Print("Short won: " + double(shortsWon));
         Print("Initial balance: " + double(initialBalance));
         Print("Date from: " + double(dateFrom));
         Print("Date to: " + double(dateTo));
         Print("Total trades: " + double(totalTrades));
         Print("Long trades: " + double(longTrades));
         Print("Short trades: " + double(shortTrades));
         Print("Consecutive wins: " + double(consecutiveWins));
         Print("Consecutive loses: " + double(consecutiveLoses));
      }
      
      void savePosition(Position* position) {
         ArrayResize(positions, ArraySize(positions) + 1); 
         positions[ArraySize(positions) - 1] = position; 
      }
};

