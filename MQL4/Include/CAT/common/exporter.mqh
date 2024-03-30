#include <CAT/common/database/db.mqh>
#include <CAT/common/database/queries.mqh>
#include <CAT/common/session.mqh>
#include <CAT/common/logger.mqh>

class BacktestExporter {
    private:
        Database* db;
        
        string strategyName;
        string sessionLimits;
        string dateFrom;
        double accountStartBalance;

    public:
        BacktestExporter(string cStrategyName, string cSessionLimits) {
            this.db = new Database();

            this.strategyName = cStrategyName;
            this.sessionLimits = cSessionLimits;
            this.accountStartBalance = AccountBalance();
            this.dateFrom = getCurrentDateTime();
        }

        ~BacktestExporter() {
            delete db;
        }

        void exportBacktest() {
            if (TesterStatistics(STAT_PROFIT_FACTOR) <= 1.3) return;

            string backtestQuery = setBacktestDataQuery(accountStartBalance, dateFrom, sessionLimits, strategyName);
            db.insertData(backtestQuery);

            int btId = (int)db.lastInsertId();
            string positionsQuery = insertPositionsQuery(btId);
            db.insertData(positionsQuery);
        }

};
