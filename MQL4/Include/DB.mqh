//+------------------------------------------------------------------+
//|                                                           DB.mqh |
//|                                                            Tykee |
//|                                              http://www.tykee.io |
//+------------------------------------------------------------------+
#property copyright "Tykee"
#property link      "http://www.tykee.io"
#property strict

#include <SQLite3/Statement.mqh>
#include <queries.mqh>
#include <backtest.mqh>



class Database
  {
   
   private:
      string dbName;
      string filesPath;
      string dbPath;
      SQLite3* db;
      
   int findModelId(string modelName, string modelInputs) {
      int modelId = -1;
      string query = findModelQuery(modelName, modelInputs);
      Statement s(db, query);
      
      
      int r = s.step();
      do {
         if(r == SQLITE_ROW) {
            s.getColumn(0, modelId);
         }
         else break;
   
         r=s.step();
      } while(r != SQLITE_DONE);
      return modelId;
   }
      
      
   public:
      Database::Database(void) {
         dbName = "TykeeDB.db";
         filesPath = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";
         dbPath = filesPath + "\\" + dbName;
         SQLite3::initialize();
         db = new SQLite3(dbPath, SQLITE_OPEN_READWRITE);
      };
      
      Database::Database(string name) {
         dbName = name;
         filesPath = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";
         dbPath = filesPath + "\\" + dbName;
      };
     
     int getSymbolId(string symbol) {
         int symbolId;
         string query = getSymbolIdQuery(symbol);
         
         Statement statement(db, query);
         if(!statement.isValid())Print(">> SQLite: Faild to execute getSymbolIdQuery....", db.getErrorMsg());
         
         int row = statement.step();
         do {
           if(row==SQLITE_ROW) statement.getColumn(0,symbolId);
         }
         while(row!=SQLITE_DONE);
         SQLite3::shutdown();
         return symbolId;
     }
     
      int getModelId(string modelName, string modelInputs) {
           int modelId = findModelId(modelName, modelInputs);
           if (modelId != -1) {
               return modelId;
           } else {
               insertData(insertModelQuery(modelName, modelInputs));
               return findModelId(modelName, modelInputs);
           }
      }
        
      void insertData(string sql) {
         if(!db.isValid()) Print(">> SQLite: Failed to connect...  ", db.getErrorMsg());
         
         Statement s(db,sql);
   
         if(!s.isValid()) {
            Print(db.getErrorMsg());
            return;
         }
         
         int r = s.step();
         if(r == SQLITE_OK) {
           Print(">>> Step finished.");
         } else if(r==SQLITE_DONE)
           Print(">>> Successfully created table.");
          else
           Print(">>> Error executing statement: ",db.getErrorMsg());
         }
  };
