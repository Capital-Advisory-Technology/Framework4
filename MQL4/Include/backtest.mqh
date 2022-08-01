
#include <position.mqh>

const string DATE_FORMAT = "";

class BacktestInfo {

   private:
      string name; // done
      string modelName; // done
      string modelParamsJson; // done
      double profit; 
      double profit_factor;
      double drawdown;
      double longsWon; // done
      double shortsWon; // done
      int dateFrom; // done
      int dateTo; //done
      int totalTrades; // done
      int longTrades; //done
      int shortTrades; //done
      int consecutiveWins; //done
      int consecutiveLoses; //done
      Position* positions[];
      
      
      void doCalculations() {
          int positionAmount = ArraySize(positions);
          // Total trades
          totalTrades = positionAmount;
          
          
          int tempConsecutiveLoses = 0;
          int tempConsecutiveWins = 0;
          
          for (int i = 0; i < positionAmount; i++) {
            Position* pos = positions[i];
            
            
            // Consecutive params
            if (pos.getProfit() > 0) {
              tempConsecutiveWins++;
              tempConsecutiveLoses = 0;
              if (tempConsecutiveWins > consecutiveWins) consecutiveWins = tempConsecutiveWins;
            } else {
               tempConsecutiveLoses++;
               if (tempConsecutiveLoses > consecutiveLoses) consecutiveLoses = tempConsecutiveLoses;
               tempConsecutiveWins = 0;
            }
            
             
            int tempLongsWon = 0;
            int tempShortsWon = 0;
            if (pos.getPositionType() == 0) {
                if (pos.getProfit() > 0) tempLongsWon++;
               longTrades++;
            } else {
               if (pos.getProfit() > 0) tempShortsWon++;
               shortTrades++;
            }
            
            longsWon = tempLongsWon / longTrades;
            shortsWon = tempShortsWon / shortsWon;
          }
      }
      
      
   public: 
      BacktestInfo::BacktestInfo(string backtestName, string newModelName, string modelParams) {
         this.name = backtestName;
         this.modelName = newModelName;
         this.modelParamsJson = modelParams;
      };
      
      void setDate(datetime date){
         if (dateFrom == NULL) {
            dateFrom = date;
         }
         dateTo = date;
      };
      
      void exportBacktestData() {
         doCalculations();
         
      }
      
      void savePosition(Position* position) {
         ArrayResize(positions, ArraySize(positions) + 1); 
         positions[ArraySize(positions) - 1] = position; 
      }
};


