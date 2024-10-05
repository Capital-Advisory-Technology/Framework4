#include <CAT/common/json.mqh>

string insertBacktestQuery(
    string strategyName, string inputs, string sessionLimits, double accountStartBalance, string dateFrom) {
    int isOptimization = (int)IsOptimization();

    string dateTo = getCurrentDateTime();
    string accountCurrency = AccountInfoString(ACCOUNT_CURRENCY);

    string query = "INSERT INTO backtests";
    StringAdd(query, " (strategy_name, inputs, session_limits, symbol, period, account_currency, account_balance, date_from, date_to, is_optimization)");
    string valueStr = StringFormat(" VALUES ('%s', '%s', '%s', '%s', %d, '%s', %f, '%s', '%s', %d)",
                                   strategyName, inputs, sessionLimits, Symbol(), Period(), accountCurrency, accountStartBalance, dateFrom, dateTo, isOptimization);
    StringAdd(query, valueStr);
    return query;
}

void insertPositionsQueries(int backtestId, string & queries[]) {
    int historyTotal = OrdersHistoryTotal();
    string query;
    for (int i = 0; i < historyTotal; i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            if (i % 10 == 0) {
                query = "INSERT INTO positions";
                StringAdd(query, " (backtest_id, order_number, type, open_time, close_time, lot_size, open_price, close_price, sl_price, tp_price, net_profit, gross_profit, commission, swap) VALUES ");
            }

            string openTime = getStrDateTime(OrderOpenTime());
            string closeTime = getStrDateTime(OrderCloseTime());

            double lotSize = NormalizeDouble(OrderLots(), 2);
            double openPrice = NormalizeDouble(OrderOpenPrice(), Digits);
            double closePrice = NormalizeDouble(OrderClosePrice(), Digits);
            double slPrice = NormalizeDouble(OrderStopLoss(), Digits);
            double tpPrice = NormalizeDouble(OrderTakeProfit(), Digits);

            double grossProfit = NormalizeDouble(OrderProfit(), 2);
            double commission = NormalizeDouble(OrderCommission(), 2);
            double swap = NormalizeDouble(OrderSwap(), 2);
            double netProfit = NormalizeDouble(grossProfit + commission + swap, 2);

            string position = StringFormat(
                "(%d, %d, %d, '%s', '%s', %f, %f, %f, %f, %f, %f, %f, %f, %f)",
                backtestId, OrderTicket(), OrderType(), openTime, closeTime, lotSize, openPrice, closePrice,
                slPrice, tpPrice, netProfit, grossProfit, commission, swap
            );
            StringAdd(query, position);

            if (i % 10 == 9 || i == historyTotal - 1) {
                StringAdd(query, ";");
                ArrayResize(queries, ArraySize(queries) + 1);
                queries[ArraySize(queries)- 1] = query;

            } else StringAdd(query, ", ");
        }
    }
}

string getStrDateTime(datetime dt) {
    return TimeToStr(dt, TIME_DATE | TIME_SECONDS);
}

string getCurrentDateTime() {
    return getStrDateTime(iTime(Symbol(), Period(), 0));
}