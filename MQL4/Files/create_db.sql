DROP TABLE IF EXISTS position_types;
CREATE TABLE IF NOT EXISTS position_types
(
    id   INTEGER PRIMARY KEY,
    value INTEGER NOT NULL,
    name TEXT    NOT NULL
);

INSERT INTO position_types (value, name)
VALUES (0, 'Long'), (1, 'Short');


DROP TABLE IF EXISTS periods;
CREATE TABLE IF NOT EXISTS periods
(
    id   INTEGER PRIMARY KEY,
    value INTEGER NOT NULL,
    name TEXT NOT NULL
);
INSERT INTO periods (value, name)
VALUES (1, 'M1')
     , (5, 'M5')
     , (10, 'M10')
     , (15, 'M15')
     , (30, 'M30')
     , (60, 'H1')
     , (240, 'H4')
     , (1440, 'DAY')
     , (7200, 'WEEK')
     , (28800, 'MONTH')
;

DROP TABLE IF EXISTS symbols;
CREATE TABLE IF NOT EXISTS symbols
(
    id       INTEGER PRIMARY KEY,
    name     TEXT    NOT NULL,
    base     TEXT    NOT NULL,
    exchange TEXT    NOT NULL,
    digits   INTEGER NOT NULL
);

INSERT INTO symbols (name, base, exchange, digits)
VALUES ('AUDCAD', 'AUD', 'CAD', 5)
     , ('AUDCHF', 'AUD', 'CHF', 5)
     , ('AUDJPY', 'AUD', 'JPY', 3)
     , ('AUDNZD', 'AUD', 'NZD', 5)
     , ('AUDUSD', 'AUD', 'USD', 5)
     , ('CADCHF', 'CAD', 'CHF', 5)
     , ('CADJPY', 'CAD', 'JPY', 3)
     , ('CHFJPY', 'CHF', 'JPY', 3)
     , ('EURAUD', 'EUR', 'AUD', 5)
     , ('EURCAD', 'EUR', 'CAD', 5)
     , ('EURCHF', 'EUR', 'CHF', 5)
     , ('EURGBP', 'EUR', 'GBP', 5)
     , ('EURJPY', 'EUR', 'JPY', 3)
     , ('EURNZD', 'EUR', 'NZD', 5)
     , ('EURUSD', 'EUR', 'USD', 5)
     , ('GBPAUD', 'GBP', 'AUD', 5)
     , ('GBPCAD', 'GBP', 'CAD', 5)
     , ('GBPCHF', 'GBP', 'CHF', 5)
     , ('GBPJPY', 'GBP', 'JPY', 3)
     , ('GBPNZD', 'GBP', 'NZD', 5)
     , ('GBPUSD', 'GBP', 'USD', 5)
     , ('NZDCAD', 'NZD', 'CAD', 5)
     , ('NZDCHF', 'NZD', 'CHF', 5)
     , ('NZDJPY', 'NZD', 'JPY', 3)
     , ('NZDUSD', 'NZD', 'USD', 5)
     , ('USDCAD', 'USD', 'CAD', 5)
     , ('USDCHF', 'USD', 'CHF', 5)
     , ('USDJPY', 'USD', 'JPY', 3)
;

DROP TABLE IF EXISTS backtests_raw;
CREATE TABLE IF NOT EXISTS backtests_raw (
    id                INTEGER PRIMARY KEY,
    symbol         INTEGER NOT NULL,
    period            INTEGER NOT NULL,
    account_currency  TEXT NOT NULL,
    account_balance  REAL NOT NULL,
    date_from         INTEGER NOT NULL,
    date_to           INTEGER NOT NULL,
    session_limits    TEXT    NOT NULL,

    strategy_name            TEXT    NOT NULL,
    profit                 REAL    NOT NULL,
    trades                 INTEGER NOT NULL,
    profit_factor          REAL    NOT NULL,
    expected_payoff        REAL    NOT NULL,
    drawdown               REAL    NOT NULL,
    drawdown_percent       REAL    NOT NULL
    -- entry_list        TEXT    NOT NULL,
    -- exit_list         TEXT    NOT NULL,
    -- confirmation_list TEXT    NOT NULL,
    -- FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE,
    -- FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    -- FOREIGN KEY (period) REFERENCES periods (id) ON DELETE CASCADE
    -- ,UNIQUE(strategy_id, symbol_id, period, date_from, date_to, inputs)

);

DROP TABLE IF EXISTS positions;
CREATE TABLE IF NOT EXISTS positions
(
    id             INTEGER PRIMARY KEY,
    bt_raw_id    INTEGER NOT NULL,
    type           INT     NOT NULL,
    order_number   INTEGER NOT NULL,
    open_time      TEXT    NOT NULL,
    close_time     TEXT    NOT NULL,
    lot_size       REAL    NOT NULL,
    open_price     REAL    NOT NULL,
    close_price    REAL    NOT NULL,
    sl_price       REAL    NOT NULL,
    tp_price       REAL    NOT NULL,
    gross_profit   REAL    NOT NULL,
    net_profit     REAL    NOT NULL,
    commission     REAL    NOT NULL,
    swap           REAL    NOT NULL,

    FOREIGN KEY (bt_raw_id) REFERENCES backtests_raw (id) ON DELETE CASCADE
);
