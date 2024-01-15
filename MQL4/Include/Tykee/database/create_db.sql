DROP TABLE IF EXISTS position_types;
CREATE TABLE IF NOT EXISTS position_types(
	id INTEGER NOT NULL
	,name TEXT NOT NULL
	,UNIQUE(id)
);

INSERT INTO position_types (id, name)
VALUES
(0, "Long")
,(1, "Short")
;


DROP TABLE IF EXISTS breakeven_flags;
CREATE TABLE IF NOT EXISTS breakeven_flags(
	id INTEGER NOT NULL
	,name TEXT NOT NULL
	,UNIQUE(id)
);
INSERT INTO breakeven_flags (id, name)
VALUES
(0, "No BreakEven")
,(1, "BreakEven")
;

DROP TABLE IF EXISTS close_types;
CREATE TABLE IF NOT EXISTS close_types(
	id INTEGER NOT NULL
	,name TEXT NOT NULL
	,UNIQUE(id)
);
INSERT INTO close_types (id, name)
VALUES
(0, "Manual")
,(1, "Automatic")
;

DROP TABLE IF EXISTS periods;
CREATE TABLE IF NOT EXISTS periods(
	id INTEGER NOT NULL
	,name TEXT NOT NULL
	,UNIQUE(id)
);
INSERT INTO periods
VALUES
(1, "M1")
,(5, "M5")
,(10, "M10")
,(15, "M15")
,(30, "M30")
,(60, "H1")
,(240, "H4")
,(1440, "DAY")
,(7200, "WEEK")
,(28800, "MONTH")
;

DROP TABLE IF EXISTS symbols;
CREATE TABLE IF NOT EXISTS symbols(
	id INTEGER PRIMARY KEY
	,name TEXT NOT NULL
	,base TEXT NOT NULL
	,exchange TEXT NOT NULL
	,digits INTEGER NOT NULL
	,UNIQUE(id)
);

INSERT INTO symbols (name, base, exchange, digits)
VALUES
("AUDCAD", "AUD", "CAD", 5)
,("AUDCHF", "AUD", "CHF", 5)
,("AUDJPY", "AUD", "JPY", 3)
,("AUDNZD", "AUD", "NZD", 5)
,("AUDUSD", "AUD", "USD", 5)
,("CADCHF", "CAD", "CHF", 5)
,("CADJPY", "CAD", "JPY", 3)
,("CHFJPY", "CHF", "JPY", 3)
,("EURAUD", "EUR", "AUD", 5)
,("EURCAD", "EUR", "CAD", 5)
,("EURCHF", "EUR", "CHF", 5)
,("EURGBP", "EUR", "GBP", 5)
,("EURJPY", "EUR", "JPY", 3)
,("EURNZD", "EUR", "NZD", 5)
,("EURUSD", "EUR", "USD", 5)
,("GBPAUD", "GBP", "AUD", 5)
,("GBPCAD", "GBP", "CAD", 5)
,("GBPCHF", "GBP", "CHF", 5)
,("GBPJPY", "GBP", "JPY", 3)
,("GBPNZD", "GBP", "NZD", 5)
,("GBPUSD", "GBP", "USD", 5)
,("NZDCAD", "NZD", "CAD", 5)
,("NZDCHF", "NZD", "CHF", 5)
,("NZDJPY", "NZD", "JPY", 3)
,("NZDUSD", "NZD", "USD", 5)
,("USDCAD", "USD", "CAD", 5)
,("USDCHF", "USD", "CHF", 5)
,("USDJPY", "USD", "JPY", 3)
;

DROP TABLE IF EXISTS strategies;
CREATE TABLE IF NOT EXISTS strategies(
	id INTEGER PRIMARY KEY
	,name TEXT NOT NULL
	,UNIQUE(name)
);

DROP TABLE IF EXISTS backtests;
CREATE TABLE IF NOT EXISTS backtests(
	id INTEGER PRIMARY KEY
	,strategy_id INTEGER NOT NULL
	,symbol_id INTEGER NOT NULL
	,period INTEGER NOT NULL
	,account_currency INTEGER NOT NULL
	,date_from INTEGER NOT NULL
	,date_to INTEGER NOT NULL
	,balance INTEGER NOT NULL
	,session_limits TEXT NOT NULL
	,inputs TEXT NOT NULL
	,entry_list TEXT NOT NULL
	,exit_list TEXT NOT NULL
	,confirmation_list TEXT NOT NULL
	,FOREIGN KEY(strategy_id) REFERENCES strategies(id) ON DELETE CASCADE
	,FOREIGN KEY(symbol_id) REFERENCES symbols(id) ON DELETE CASCADE
	,FOREIGN KEY(period) REFERENCES periods(id) ON DELETE CASCADE
	-- ,UNIQUE(strategy_id, symbol_id, period, date_from, date_to, inputs)

);

DROP TABLE IF EXISTS positions;
CREATE TABLE IF NOT EXISTS positions(
	id INTEGER PRIMARY KEY
	,backtest_id INTEGER NOT NULL
	,order_number INTEGER NOT NULL
	,open_time TEXT NOT NULL
	,close_time TEXT NOT NULL
	,position_type INT NOT NULL
	,lot_size REAL NOT NULL
	,open_price REAL NOT NULL
	,close_price REAL NOT NULL
	,sl_price REAL NOT NULL
	,tp_price REAL NOT NULL
	,gross_profit REAL NOT NULL
	,net_profit REAL NOT NULL
	,commission REAL NOT NULL
	,swap REAL NOT NULL
	,breakeven_flag INTEGER NOT NULL
	,close_type INTEGER NOT NULL
	,FOREIGN KEY(backtest_id) REFERENCES backtests(id) ON DELETE CASCADE
	,FOREIGN KEY(position_type) REFERENCES position_types(id) ON DELETE CASCADE
	,FOREIGN KEY(breakeven_flag) REFERENCES breakeven_flags(id) ON DELETE CASCADE
	,FOREIGN KEY(close_type) REFERENCES close_types(id) ON DELETE CASCADE
);
