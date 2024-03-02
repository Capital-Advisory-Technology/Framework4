#include <CAT/common/position.mqh>
#include <CAT/common/session.mqh>
#include <CAT/common/extensions.mqh>
#include <CAT/http/request.mqh>
#include <CAT/database/db.mqh>

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
      BacktestInfo::BacktestInfo(string cModelName, string cModelParams, bool cExportData) {
         this.initialBalance = AccountBalance();
         this.modelName = cModelName;
         this.inputJson = cModelParams;
         this.exportData = cExportData;
         this.db = new Database();
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
      
      void exportBacktest() {
         if (!exportData) return;
         toSqlite();
         SendRequest("POST", "/api/backtest/", toJson());
         
      }
      
      void savePosition(Position* position) {
         ArrayResize(positions, ArraySize(positions) + 1); 
         positions[ArraySize(positions) - 1] = position; 
      }
      
      bool getExportData() {
         return exportData;
      }
      
      void setCustomSessionObject(CustomSession* cCustomSession) {
         this.customSession = cCustomSession;
      }

   private:
      bool exportData;
      string modelName;
      string inputJson; 
      double initialBalance;
      int dateFrom; 
      int dateTo;
      Position* positions[];
      CustomSession* customSession;
      Database *db;
      
      string toJson() {
         CJAVal backtestObject;
         backtestObject["strategy"] = modelName;
         backtestObject["symbol"] = Symbol();
         backtestObject["period"] = Period();
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
         
         CJAVal json;
         json["backtest"] = backtestObject;
         json["positions"] = positionObject;

         return json.Serialize(); 
      }

      void toSqlite() {
         int symbolId = db.getSymbolId(Symbol());
         int strategyId = db.getStrategyId(modelName);
         string backtestSql = setBacktestDataQuery(
            symbolId, strategyId, Period(), initialBalance, dateFrom, dateTo, customSession.toJson(), inputJson, stringListToJson(entryFunctionList), stringListToJson(exitFunctionList), stringListToJson(confirmFunctionList), AccountCurrency()
         );
         db.insertData(backtestSql);
         long backtestId = db.lastInsertId();

         for (int i = 0; i < ArraySize(positions); i++) {
            db.insertData(positions[i].getSql(backtestId));
         }
      }

};

 void addToEntryFunctionList(string name) {
   for (int i = 0; i < ArraySize(entryFunctionList); i++) {
      if (entryFunctionList[i] == name) return;
   }

   ArrayResize(entryFunctionList, ArraySize(entryFunctionList) + 1); 
   entryFunctionList[ArraySize(entryFunctionList) - 1] = name;
}

 void addToExitFunctionList(string name) {
   for (int i = 0; i < ArraySize(exitFunctionList); i++) {
      if (exitFunctionList[i] == name) return;
   }
   ArrayResize(exitFunctionList, ArraySize(exitFunctionList) + 1); 
   exitFunctionList[ArraySize(exitFunctionList) - 1] = name;
}

 void addToConfirmationFunctionList(string name) {
   for (int i = 0; i < ArraySize(confirmFunctionList); i++) {
      if (confirmFunctionList[i] == name) return;
   }
   ArrayResize(confirmFunctionList, ArraySize(confirmFunctionList) + 1); 
   confirmFunctionList[ArraySize(confirmFunctionList) - 1] = name;
}
