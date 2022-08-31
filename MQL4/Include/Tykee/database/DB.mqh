//+------------------------------------------------------------------+
//|                                                           DB.mqh |
//|                                                            Tykee |
//|                                              http://www.tykee.io |
//+------------------------------------------------------------------+
#property copyright "Tykee"
#property link      "http://www.tykee.io"
#property strict

#include <SQLite3/Statement.mqh>

#include <Tykee/main/backtest.mqh>
#include <Tykee/database/queries.mqh>

/*
   Database class to establish connection with DB and execute queries.
*/
class Database
  {
   
   private:
      string dbName;
      string filesPath;
      string dbPath;
      SQLite3* db;

      int findStrategyId(string modelName) {
         int strategyId = -1;
         string query = findStrategyQuery(modelName);
         Statement s(db, query);
         if(!s.isValid())Print(">> SQLite: Faild to execute getSymbolIdQuery....", db.getErrorMsg());
         
         int r = s.step();
         do {
            if(r == SQLITE_ROW) {
               s.getColumn(0, strategyId);
            } else {
               break;
            }
      
            r=s.step();
         } while(r != SQLITE_DONE);
         return strategyId;
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
         SQLite3::initialize();
         db = new SQLite3(dbPath, SQLITE_OPEN_READWRITE);
      };
      
      ~Database() {
       SQLite3::shutdown();
      } 
     
     int getSymbolId(string symbol) {
         int symbolId = -1;
         string query = getSymbolIdQuery(symbol);
         Statement s(db, query);
         if(!s.isValid())Print(">> SQLite: Faild to execute getSymbolIdQuery....", db.getErrorMsg());
         
         int r = s.step();
         do {
            if(r == SQLITE_ROW) {
               s.getColumn(0, symbolId);
            } else {
               break;
            }
      
            r=s.step();
          } while(r != SQLITE_DONE);
          return symbolId;
     }
     
     
     int getDateTime() {
         int datetimeInt = 0;
         Statement s(db, getCurrentTimeQuery());
         if(!s.isValid() )Print(">> SQLite: Faild to execute", db.getErrorMsg());
         
         int r = s.step();
         do {
            if(r == SQLITE_ROW) {
               s.getColumn(0, datetimeInt);
            } else {
               break;
            }
      
            r=s.step();
          } while(r != SQLITE_DONE);
          return datetimeInt;
     }
     
     int getStrategyId(string modelName) {
           int strategyId = findStrategyId(modelName);
           if (strategyId != -1) {
               return strategyId;
           } else {
               insertData(insertStrategyQuery(modelName));
               return findStrategyId(modelName);
           }
      }      

      /*
         Use this to execute any sql which does not require data to
         be collected f.e. INSERT, MODIFY etc. Dont execute SELECT queries with this.
      */
      void insertData(string sql) {
         Statement s(db,sql);
         if(!s.isValid()) {
            Print(db.getErrorMsg());
            return;
         }
         
         int r = s.step();
         if(r == SQLITE_OK) {
           Print(">>> Step finished.");
         } else if(r==SQLITE_DONE) {
           // Ignore
         } else
           Print(">>> Error executing statement: ",db.getErrorMsg());
         }
            
      int findBacktestId(int backtestLaunchTime) {
         int backtestId = -1;
         string query = findBacktestQuery(backtestLaunchTime);
         Statement s(db, query);
         
         int r = s.step();
         do {
            if(r == SQLITE_ROW) {
               s.getColumn(0, backtestId);
            }
            else break;
      
            r=s.step();
         } while(r != SQLITE_DONE);
         return backtestId;
      }
};
