import logging
import traceback

import polars as pl

logger = logging.getLogger('calculations')
logger.setLevel(logging.INFO)


def add_balance_column(positions: list[dict], start_balance: float) -> pl.DataFrame:
    pos_df = pl.DataFrame(positions)
    pos_df = pos_df.with_columns(
        pl.col("open_time").str.to_datetime(format="%Y.%m.%d %H:%M:%S"),
        pl.col("close_time").str.to_datetime(format="%Y.%m.%d %H:%M:%S"),
        (pl.col("net_profit").cumsum() + start_balance).alias("balance")
    )
    return pos_df


def balance_stats(positions: pl.DataFrame):
    results = {
        "start_balance": 0,
        "final_balance": 0,
        "min_balance": 0,
        "max_balance": 0,
        "net_profit": 0,
        "net_profit_percent": 0,
        "profit_factor": 0,
        "trans_cost_percent": 0,
    }
    if positions.shape[0] == 0:
        return results

    start_balance = round(positions['balance'][0] - positions['net_profit'][0], 2)
    final_balance = round(positions['balance'][-1], 2)

    results["start_balance"] = start_balance
    results["final_balance"] = final_balance
    results["min_balance"] = round(positions['balance'].min(), 2)
    results["max_balance"] = round(positions['balance'].max(), 2)
    results["net_profit"] = round(final_balance - start_balance, 2)
    results["net_profit_percent"] = round(((final_balance / start_balance - 1) * 100), 2)

    pos_profit_sum = positions.filter(pl.col('net_profit') > 0)['net_profit'].sum()
    neg_profit_sum = abs(positions.filter(pl.col('net_profit') < 0)['net_profit'].sum())
    profit_factor = pos_profit_sum / neg_profit_sum if neg_profit_sum != 0 else 0
    results["profit_factor"] = round(profit_factor, 2)

    net_profit = abs(positions.select(
        pl.when(pl.col('net_profit') == 0.0).then(0.01).otherwise(pl.col('net_profit')).alias('net_profit')
    )['net_profit'].sum())
    net_profit = 0.01 if net_profit == 0 else net_profit
    transaction_cost = (positions['commission'].sum() + positions['swap'].sum()) / abs(net_profit) * 100
    results["trans_cost_percent"] = round(transaction_cost, 2)

    return results


def drawdown_stats(positions: pl.DataFrame, backtest: dict):
    results = {
        "avg_drawdown": 0,
        "max_drawdown": 0,
        "min_drawdown": 0,
        "avg_dd_duration": 0,
        "max_dd_duration": 0,
        "min_dd_duration": 0,
        "max_drawdown_duration": 0
    }
    if positions.shape[0] == 0:
        return results

    datetime = pl.concat([
        pl.Series([backtest["date_from"]]).str.to_datetime(format="%Y.%m.%d %H:%M:%S"),
        positions['close_time']
    ])

    # datetime = datetime.str.to_datetime(format="%Y.%m.%d %H:%M:%S")
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

    if group_df.shape[0] == 0:
        return results

    group_dd = group_df['dd_rel']
    group_duration = group_df['duration']

    if group_dd.shape[0] != 0:
        results["avg_drawdown"] = round(group_dd.mean(), 2)
        results["max_drawdown"] = round(group_dd.min(), 2)
        results["min_drawdown"] = round(group_dd.max(), 2)

    if group_duration.shape[0] != 0:
        results["avg_dd_duration"] = int(group_duration.mean().total_seconds())
        results["max_dd_duration"] = int(group_duration.max().total_seconds())
        results["min_dd_duration"] = int(group_duration.min().total_seconds())
        results["max_drawdown_duration"] = int(
            group_df.filter(pl.col("dd_rel") == group_dd.min())['duration'].max().total_seconds())

    return results


def trade_stats(positions: pl.DataFrame):
    results = {
        "total_trades": 0,
        "long_trades": 0,
        "short_trades": 0,
        "long_wins": 0,
        "short_wins": 0,
        "long_wr": 0,
        "short_wr": 0,
        "long_pf": 0,
        "short_pf": 0,
        "win_rate": 0,
        "breakeven_wr": 0
    }
    if positions.shape[0] == 0:
        return results
    total_trades = positions['type'].count()
    # position types: 0 - long, 1 - short
    long_trades = positions.filter(pl.col('type') == 0)['type'].count()
    short_trades = positions.filter(pl.col('type') == 1)['type'].count()

    results["total_trades"] = total_trades
    results["long_trades"], results["short_trades"] = long_trades, short_trades

    long_wins = positions.filter((pl.col('type') == 0) & (pl.col('net_profit') > 0))['type'].count()
    short_wins = positions.filter((pl.col('type') == 1) & (pl.col('net_profit') > 0))['type'].count()
    long_wr = round(long_wins / long_trades * 100, 2) if long_trades != 0 else 0
    short_wr = round(short_wins / short_trades * 100, 2) if short_trades != 0 else 0
    results["long_wins"], results["short_wins"] = long_wins, short_wins
    results["long_wr"], results["short_wr"] = long_wr, short_wr

    long_loss = abs(positions.filter((pl.col('type') == 0) & (pl.col('net_profit') < 0))['net_profit'].sum())
    long_pf = (positions.filter((pl.col('type') == 0) & (pl.col('net_profit') > 0))['net_profit'].sum() /
               long_loss) if long_trades != 0 and long_loss != 0 else 0
    results["long_pf"] = round(long_pf, 2)

    short_loss = abs(positions.filter((pl.col('type') == 1) & (pl.col('net_profit') < 0))['net_profit'].sum())
    short_pf = (positions.filter((pl.col('type') == 1) & (pl.col('net_profit') > 0))['net_profit'].sum() /
                short_loss) if short_trades != 0 and short_loss != 0 else 0
    results["short_pf"] = round(short_pf, 2)

    win_rate = round((long_wins + short_wins) / total_trades * 100, 2)
    results["win_rate"] = win_rate
    # TODO: breakeven win rate from input SL TP ratio
    return results


def consecutive_stats(positions: pl.DataFrame):
    results = {
        "max_cons_wins": 0,
        "avg_cons_wins": 0,
        "max_cons_w_duration": 0,
        "avg_cons_w_duration": 0,

        "max_cons_losses": 0,
        "avg_cons_losses": 0,
        "max_cons_l_duration": 0,
        "avg_cons_l_duration": 0
    }
    if positions.shape[0] == 0:
        return results

    cons_df = positions.with_columns(
        pl.col("close_time").alias("dt"),
        pl.col('gross_profit').gt(0).cast(pl.UInt32).alias('win'),
        pl.col('gross_profit').lt(0).cast(pl.UInt32).alias('loss'),
    )
    cons_df = cons_df.with_columns(
        pl.col('win').cumsum().alias('win_count'),
        pl.col('loss').cumsum().alias('loss_count')
    )
    loss_starts = cons_df['loss'].diff().fill_null(0) != 0
    l_group_id = loss_starts.cumsum()

    loss_df = pl.DataFrame({"dt": cons_df["dt"], "data": cons_df['loss'], "group_id": l_group_id})
    loss_df = loss_df.with_columns(
        pl.when(loss_df["data"] == 1)
        .then(pl.col("data").cumsum().over("group_id"))
        .otherwise(0)
        .alias("sequence")
    ).filter(pl.col("data") == 1)

    loss_results = loss_df.groupby("group_id").agg(
        pl.col("sequence").max().alias("max_loss"),
        (pl.col("dt").last() - pl.col("dt").first()).alias("duration")
    )

    win_starts = cons_df['win'].diff().fill_null(0) != 0
    w_group_id = win_starts.cumsum()
    win_df = pl.DataFrame({"dt": cons_df["dt"], "data": cons_df['win'], "group_id": w_group_id})
    win_df = win_df.with_columns(
        pl.when(win_df["data"] == 1)
        .then(pl.col("data").cumsum().over("group_id"))
        .otherwise(0)
        .alias("sequence")
    ).filter(pl.col("data") == 1)

    win_results = win_df.groupby("group_id").agg(
        pl.col("sequence").max().alias("max_win"),
        (pl.col("dt").last() - pl.col("dt").first()).alias("duration")
    )

    if win_results.shape[0] > 0:
        results["max_cons_wins"] = int(cons_df['win_count'].max())
        results["avg_cons_wins"] = round(win_results['max_win'].mean(), 2)
        results["max_cons_w_duration"] = int(win_results['duration'].mean().total_seconds())
        results["avg_cons_w_duration"] = int(win_results['duration'].mean().total_seconds())

    if loss_results.shape[0] > 0:
        results["max_cons_losses"] = int(cons_df['loss_count'].max())
        results["avg_cons_losses"] = round(loss_results['max_loss'].mean(), 2)
        results["max_cons_l_duration"] = int(loss_results['duration'].mean().total_seconds())
        results["avg_cons_l_duration"] = int(loss_results['duration'].mean().total_seconds())

    return results


def get_stats(backtest: dict, positions: pl.DataFrame):
    try:
        balance = balance_stats(positions)
        drawdown = drawdown_stats(positions, backtest)
        trades = trade_stats(positions)
        consecutive = consecutive_stats(positions)

        return {
            "balance": balance,
            "drawdown": drawdown,
            "trades": trades,
            "consecutive": consecutive
        }
    except Exception as e:
        tb = traceback.format_exc()
        logger.error(f"Error calculating stats: {e} \n{tb}")

        return {"error": f"Error calculating stats: {e}"}


def calculate_stats(backtest: dict, positions: list[dict]):
    position_df = add_balance_column(positions, backtest["account_balance"])

    overall_stats = get_stats(backtest, position_df)

    yearly_stats = []
    for year in position_df["close_time"].dt.year().unique():
        year_df = position_df.filter(pl.col('close_time').dt.year() == year)
        year_stats = get_stats(backtest, year_df)
        yearly_stats.append({f"{year}": year_stats})

    monthly_stats = []
    monthly_df = position_df.with_columns(
        pl.datetime(pl.col('close_time').dt.year(), pl.col('close_time').dt.month(), 1).alias("month_start")
    )

    for month in monthly_df["month_start"].unique():
        month_df = monthly_df.filter(pl.col('month_start') == month)
        if month_df.shape[0] != 0:
            month_stats = get_stats(backtest, month_df)
            monthly_stats.append({month.strftime('%Y-%m-%d'): month_stats})

    return {
        "overall": overall_stats,
        "yearly": yearly_stats,
        "monthly": monthly_stats
    }
