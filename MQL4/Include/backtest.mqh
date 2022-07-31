

const string DATE_FORMAT = "";

class BacktestInfo {

   private:
      string name;
      string modelName;
      string modelParamsJson;
      double profit;
      double profit_factor;
      double drawdown;
      double longsWon;
      double shortsWon;
      int dateFrom;
      int dateTo;
      int totalTrades;
      int longTrades;
      int shortTrades;
      int consecutiveWins;
      int consecutiveLoses;
      
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
      
      void printData() {
         Print("Name " + name);
         Print("ModelName " + modelName);
         Print("DateFrom " + dateFrom);
         Print("DateTo " + dateTo);
      };
};


