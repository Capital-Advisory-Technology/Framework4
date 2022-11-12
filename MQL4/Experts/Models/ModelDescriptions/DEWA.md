# DEWA

## Model descriptions

### DEWA_0
Model `DEWA_0` is an Expert Advisor that uses `DEMA` indicator for entries
and `Waddah` indicator for confirmation bias.

StopLoss - basic `ATR`.

### DEWA_1 
Optimization from 2011.01.01. - 2021.01.01
**Balance:** 10'000.00     | **Account ccy:** EUR 
**Maximal drawdown:** 40%  |

```json
{
    "ATR_Period": 14 - 28 (2),
    "BREAK_EVEN": 0.5 - 0.8 (0.1),
    "DEMA_FilterPeriod": 0 - 8 (1),
    "DEMA_Period": 60 - 200 (20),
    "DEMA_enum_filter": 0 - 2 (1),
    "DEMA_enum_price": 0 - 32 (1),
    "DEMA_filter": 0 - 8 (1), 
    "FIXED_SLTP": false,
    "RISK_PER_TRADE": 1.0,
    "SLIPPAGE": 3,
    "SL_RATIO": 1.0 - 2.0 (0.25),
    "TP_RATIO": 8.0 - 16.0 (1.0),
    "WDH_deadZone": 20,
    "WDH_explosionPower": 15,
    "WDH_sensetive": 220,
    "WDH_trendPower": 15
}
```

### DEWA_1-1 
