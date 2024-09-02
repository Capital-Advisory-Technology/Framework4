#include <CAT/common/database/db.mqh>
#include <CAT/common/database/queries.mqh>
#include <CAT/common/session.mqh>
#include <CAT/common/logger.mqh>

class BacktestExporter {
    private:
        Database* db;

        string dateFrom;
        double accountStartBalance;


    public:
        BacktestExporter() {
            this.db = new Database();

            this.accountStartBalance = AccountBalance();
            this.dateFrom = getCurrentDateTime();
        }

        ~BacktestExporter() {
            delete db;
        }

        void exportBacktest(string strategyName, string inputs, string sessionLimits) {
            string backtestQuery = insertBacktestQuery(strategyName, inputs, sessionLimits, accountStartBalance, dateFrom);
            db.insertData(backtestQuery);

            int backtestId = db.getLastInsertId();
            string queries[];
            insertPositionsQueries(backtestId, queries);

            for (int i = 0; i < ArraySize(queries); i++) {
                // Print(queries[i]);
                db.insertData(queries[i]);
            }
            // for p in positions:
            //    string positionQuery = insertPositionQuery(p);
            //    db.insertData(positionQuery);
        }

};
