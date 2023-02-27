#include <SQLite3/Statement.mqh>

#include <Tykee/common/position.mqh>
#include <Tykee/common/session.mqh>
#include <Tykee/database/DB.mqh>
#include <Tykee/database/queries.mqh>
#include <Tykee/common/extensions.mqh>
#include <Tykee/http/request.mqh>

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
         this.shouldExportData = cShouldExportData;
         this.period = Period();
      };
      
      ~BacktestInfo() {
         for (int i = 0; i < ArraySize(positions); i++) {
            delete positions[i];
         }
         delete db;
      }
      
      void setDate(datetime date){
         if (dateFrom == NULL) {
            dateFrom = int(date);
         }
         dateTo = int(date);
      };
      
      void exportData() {
         if (!shouldExportData) return;
         SendRequest("POST", "/api/backtest/", toJson());
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
      
      string toJson() {
         CJAVal json;
         CJAVal backtestObject;
         backtestObject["symbol"] = Symbol();
         backtestObject["period"] = period;
         backtestObject["start_balance"] = initialBalance;
         backtestObject["account_currency"] = AccountCurrency();
         backtestObject["date_from"] = dateFrom;
         backtestObject["date_to"] = dateTo;
         backtestObject["inputs"] = inputJson;
         backtestObject["entry_list"] = stringListToJson(entryFunctionList);
         backtestObject["exit_list"] = stringListToJson(exitFunctionList);
         backtestObject["conf_list"] = stringListToJson(confirmFunctionList);
         backtestObject["session_limits"] = customSession.toJson();

         CJAVal positionObject;
         for (int i = 0; i < ArrayRange(positions, 0); i++) {
            positionObject.Add(positions[i].toJson());
         }
         
         json["strategy"] = modelName;
         json["backtest"] = backtestObject;
         json["positions"] = positionObject;

         return json.Serialize(); 
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
