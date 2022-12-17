# MTCodeBase
Repo for MetaTrader (MQL) code


## WebRequest

After a successful backtest a REST API call is made to our backend.

WebRequests body

```json
{
  "strategy_name": "ea-file-name.mq4",
  "backtest_info": {
    "symbol_name": "GBPJPY",
    "period_minutes": 60,
    "start_balance": 10000,
    "start_ts_utc": 123456789,
    "end_ts_utc": 198765432,
    "inputs": {"RISK_PER_TRADE": 1.0},
    "enter_list": ["Entry_1"],
    "exit_list": ["Exit_1"],
    "conf_list": ["Confirmation_1"],
    "session_limits": "{"minutes_range": [{"from": 0, "to": 55}, {}]}"
  },
  "positions": [
    {
      "order_number": 1,
      "start_ts_utc": 123456789,
      "end_ts_utc": 198765432,
      "lot_size": 0.42,
      "open_price": 123.456,
      "close_price": 123.456,
      "sl_price": 123.456,
      "tp_price": 123.456,
      "gross_profit": 123.456,
      "net_profit": 123.456,
      "commission": 123.456,
      "swap": 123.456,
      "balance": 123.456,
      "sma_200": 123.456,
      "sma_65": 123.456,
      "sma_21": 123.456,
      "ema_200": 123.456,
      "ema_65": 123.456,
      "ema_21": 123.456,
      "rsi_14": 123.456,
      "atr_14": 123.456,
      "position_type_value": 123.456,
      "breakeven_flag_value": 123.456,
      "close_type_value": 123.456
    }
  ]
}
```
