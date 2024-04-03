import polars as pl



#
# max_cons_wins REAL NOT NULL,
# max_cons_losses REAL NOT NULL,
# avg_cons_wins REAL NOT NULL,
# avg_cons_losses REAL NOT NULL,
# max_cons_l_duration REAL NOT NULL,
# max_cons_w_duration REAL NOT NULL,
# avg_cons_l_duration REAL NOT NULL,
# avg_cons_w_duration REAL NOT NULL,

def add_balance_column(positions: list[dict], start_balance: float) -> pl.DataFrame:
    pos_df = pl.DataFrame(positions)
    # pos_df = pos_df.with_columns(
    #     pl.col("open_time").str.to_datetime(format="%Y-%m-%d %H:%M:%S"),
    #     pl.col("close_time").str.to_datetime(format="%Y-%m-%d %H:%M:%S"),
    # )
    pos_df = pos_df.with_columns((pl.col("net_profit").cumsum() + start_balance).alias("balance"))
    return pos_df


def balance_stats(backtest: dict, positions: pl.DataFrame):
    start_balance = backtest["account_balance"]
    final_balance = round(start_balance + positions.select(pl.col("net_profit").sum()).to_numpy()[0][0], 2)

    profit_factor = round(
        positions.filter(pl.col('net_profit') > 0)['net_profit'].sum() /
        abs(positions.filter(pl.col('net_profit') < 0)['net_profit'].sum()),
        2
    )

    transaction_cost = round(
        (positions['commission'].sum() + positions['swap'].sum()) / positions['net_profit'].sum() * 100, 2)

    return {
        "start_balance": start_balance,
        "final_balance": final_balance,
        "min_balance": positions['balance'].min(),
        "max_balance": positions['balance'].max(),
        "net_profit": round(final_balance - start_balance, 2),
        "net_profit_percent": round(((final_balance / start_balance - 1) * 100), 2),
        "profit_factor": profit_factor,
        "trans_cost_percent": transaction_cost
    }


# avg_drawdown    REAL NOT NULL,
# max_drawdown    REAL NOT NULL,
# min_drawdown    REAL NOT NULL,
# avg_dd_duration REAL NOT NULL,
# max_dd_duration REAL NOT NULL,
# min_dd_duration REAL NOT NULL,
# max_drawdown_duration    REAL NOT NULL,


def drawdown_stats(backtest: dict, positions: pl.DataFrame):
    datetime = pl.concat([
        pl.Series([backtest["date_from"]]),
        positions['close_time']
    ])
    print(datetime)
    datetime = datetime.str.to_datetime(format="%Y.%m.%d %H:%M:%S")
    balance = pl.concat([
        pl.Series([backtest["account_balance"]]),
        positions['balance']
    ]).alias("balance")
    cummax = balance.cummax()
    dd_abs = balance - cummax
    dd_rel = ((dd_abs / cummax) * 100).round(2)

    dd_df = pl.DataFrame({
        "datetime": datetime,
        "balance": balance,
        "cummax": cummax,
        "dd_abs": dd_abs,
        "dd_rel": dd_rel,
        "group": (dd_abs == 0).cast(pl.UInt32).cumsum()
    })

    group_df = dd_df.groupby("group").agg(
        pl.col("datetime").first().alias("start_dt"),
        pl.col("datetime").last().alias("end_dt"),
        (pl.col("datetime").last() - pl.col("datetime").first()).alias("duration"),
        pl.col("balance").first().alias("start_balance"),
        pl.col("balance").last().alias("end_balance"),
        pl.col("cummax").last().alias("max_balance"),
        pl.col("dd_abs").min().alias("dd_abs"),
        pl.col("dd_rel").min().alias("dd_rel"),
        pl.col("balance").count().alias("trade_count")
    )
    group_df = group_df.filter(pl.col("dd_rel") < 0)

    group_dd = group_df['dd_rel']
    group_duration = group_df['duration']

    return {
        "avg_drawdown": round(group_dd.mean(), 2),
        "max_drawdown": round(group_dd.min(), 2),
        "min_drawdown": round(group_dd.max(), 2),
        "avg_dd_duration": group_duration.mean(),
        "max_dd_duration": group_duration.max(),
        "min_dd_duration": group_duration.min(),
        "max_drawdown_duration": group_df.filter(pl.col("dd_rel") == group_dd.min())['duration'].max()
    }


# total_trades    REAL NOT NULL,
# long_trades REAL NOT NULL,
# short_trades    REAL NOT NULL,
# long_wins   REAL NOT NULL,
# short_wins  REAL NOT NULL,
# long_wr REAL NOT NULL,
# short_wr    REAL NOT NULL,
# long_pf REAL NOT NULL,
# short_pf    REAL NOT NULL,
# win_rate    REAL NOT NULL,
# breakeven_wr    REAL NOT NULL,
def trade_stats(positions: pl.DataFrame):
    total_trades = positions['type'].count()
    # position types: 0 - long, 1 - short
    long_trades = positions.filter(pl.col('type') == 0)['type'].count()
    short_trades = positions.filter(pl.col('type') == 1)['type'].count()

    long_wins = positions.filter((pl.col('type') == 0) & (pl.col('net_profit') > 0))['type'].count()
    short_wins = positions.filter((pl.col('type') == 1) & (pl.col('net_profit') > 0))['type'].count()

    long_wr = round(long_wins / long_trades * 100, 2)
    short_wr = round(short_wins / short_trades * 100, 2)

    long_pf = round(
        positions.filter((pl.col('type') == 0) & (pl.col('net_profit') > 0))['net_profit'].sum() /
        abs(positions.filter((pl.col('type') == 0) & (pl.col('net_profit') < 0))['net_profit'].sum()),
        2
    )

    short_pf = round(
        positions.filter((pl.col('type') == 1) & (pl.col('net_profit') > 0))['net_profit'].sum() /
        abs(positions.filter((pl.col('type') == 1) & (pl.col('net_profit') < 0))['net_profit'].sum()),
        2
    )

    win_rate = round((long_wins + short_wins) / total_trades * 100, 2)
    breakeven_wr = round(positions.filter(pl.col('net_profit') == 0)['net_profit'].count() / total_trades * 100, 2)

    return {
        "total_trades": total_trades,
        "long_trades": long_trades,
        "short_trades": short_trades,
        "long_wins": long_wins,
        "short_wins": short_wins,
        "long_wr": long_wr,
        "short_wr": short_wr,
        "long_pf": long_pf,
        "short_pf": short_pf,
        "win_rate": win_rate,
        "breakeven_wr": breakeven_wr
    }


def calculate_stats(backtest: dict, positions: list[dict]):
    # for pos in positions:
    #     print(pos["close_time"])
    pos_df = add_balance_column(positions, backtest["account_balance"])
    b_stats = balance_stats(backtest, pos_df)

    dd_stats = drawdown_stats(backtest, pos_df)
    print(dd_stats)

    t_stats = trade_stats(pos_df)
    print(t_stats)
