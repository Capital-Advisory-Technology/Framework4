string setBacktestDataQuery(
    double accountStartBalance, string dateFrom,
    string sessionLimits, string strategyName
) {
    string accountCurrency = AccountInfoString(ACCOUNT_CURRENCY);
    string dateTo = getCurrentDateTime();

    double profit = NormalizeDouble(TesterStatistics(STAT_PROFIT), 2);
    int trades = (int)TesterStatistics(STAT_TRADES);
    double profitFactor = NormalizeDouble(TesterStatistics(STAT_PROFIT_FACTOR), 2);
    double expectedPayoff = NormalizeDouble(TesterStatistics(STAT_EXPECTED_PAYOFF), 2);
    double drawdown = NormalizeDouble(TesterStatistics(STAT_EQUITYDD_PERCENT), 2);
    double drawdownPercent = NormalizeDouble(TesterStatistics(STAT_EQUITY_DDREL_PERCENT), 2);
    string query = "INSERT INTO backtests_raw";
    StringAdd(query, " (symbol, period, account_currency, account_balance, date_from, date_to, session_limits, strategy_name, profit, trades, profit_factor, expected_payoff, drawdown, drawdown_percent)");
    string valueStr = StringFormat(" VALUES ('%s', %d, '%s', %f, '%s', '%s', '%s', '%s', %f, %d, %f, %f, %f, %f)",
                                   Symbol(), Period(), accountCurrency, accountStartBalance, dateFrom, dateTo, sessionLimits, strategyName, profit, trades, profitFactor, expectedPayoff, drawdown, drawdownPercent);
    StringAdd(query, valueStr);
    return query;
}

string insertPositionsQuery(int btRawId) {
    string query = "INSERT INTO positions";
    StringAdd(query, " (bt_raw_id, type, order_number, open_time, close_time, lot_size, open_price, close_price, sl_price, tp_price, net_profit, gross_profit, commission, swap) VALUES ");
    int historyTotal = OrdersHistoryTotal();
    for (int i = 0; i < historyTotal; i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
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

            string position = StringFormat("(%d, %d, %d, '%s', '%s', %f, %f, %f, %f, %f, %f, %f, %f, %f)",
                                             btRawId, OrderType(), OrderTicket(), openTime, closeTime, lotSize, openPrice, closePrice, slPrice, tpPrice, netProfit, grossProfit, commission, swap);

            if (i < historyTotal - 1) {
                StringAdd(position, ", ");
            }
            StringAdd(query, position);
        }
    }
    StringAdd(query, ";");
    return query;
}

string getStrDateTime(datetime dt) {
    return TimeToStr(dt, TIME_DATE | TIME_MINUTES);
}

string getCurrentDateTime() {
    return getStrDateTime(iTime(Symbol(), Period(), 0));
}


