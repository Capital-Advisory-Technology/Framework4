import asyncio
import json
import logging
from datetime import datetime
from pathlib import Path

import orjson
import polars as pl
from fastapi import FastAPI
from fastapi_utils.tasks import repeat_every
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.gzip import GZipMiddleware
from starlette.responses import Response

from mt4_backend.calculations import calculate_stats
from mt4_backend.database import DatabaseManager

logger = logging.getLogger('fastapi')
logger.setLevel(logging.DEBUG)

app = FastAPI(debug=True)

cors_origins = [
    'http://localhost',
    'http://localhost:5173',
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# DB_PATH = r"\MQL4\Files\mt4_backtests.db"
DB_PATH = Path(__file__).parent.parent.parent / "MQL4" / "Files" / "mt4_backtests.db"
db = DatabaseManager(DB_PATH)


@app.on_event("startup")
async def connect_db():
    await db.connect_db()
    await process_backtests()


# @app.on_event("startup")
# @repeat_every(seconds=60 * 30)
# async def scheduled_job():
#     await process_backtests()

async def process_backtests():
    unprocessed_bts = await db.get_unprocessed()
    if not unprocessed_bts:
        logger.info(f"No unprocessed backtests found.")
        return

    logger.info(f'----- Processing {len(unprocessed_bts)} backtests -----')
    for backtest in unprocessed_bts:
        backtest_id = backtest["backtest_id"]
        logger.info(f"----- Processing backtest {backtest_id} -----")

        strategy_id = await db.get_or_create_strategy(backtest["strategy_name"])
        model_id = await db.get_or_create_model(strategy_id, backtest)
        if backtest["model_id"] is None:
            await db.update_backtest_model_id(backtest_id, model_id)
        logger.info(f"----- Calculating backtest_id {backtest_id} model_id {model_id} strategy_id {strategy_id} -----")

        model_stats = await db.get_model_stats(model_id, backtest)
        if model_stats:
            logger.info(f"Model stats already exist for model_id {model_id}")
            await db.update_backtest_processed(backtest_id)
            continue

        positions = await db.get_backtest_positions(backtest_id)
        if not positions:
            logger.error(f"No positions found, dropping backtest {backtest_id}")
            await db.drop_backtest(backtest_id)
            continue

        stats = calculate_stats(backtest, positions)
        if 'error' in stats:
            logger.error(f"Error calculating stats for backtest {model_id}: {stats['error']}")
            continue

        await db.save_stats(model_id, backtest, stats)
        logger.info(f"!!!!! Stats calculated for backtest {model_id} !!!!!")

    logger.info('----- All backtests processed -----')


@app.on_event("shutdown")
async def shutdown_event():
    await db.disconnect_db()


@app.get("/models/optimization")
def read_root(
        page: int = 1,
        page_size: int = 10,
):
    now = datetime.now()
    offset = (page - 1) * page_size
    query = f"""
    select model_id, backtest_id, strategy, date_from, date_to, overall_stats
     from model_stats_view
      where is_optimization = 1 limit {page_size} offset {offset}
    """
    overall_stats = pl.read_database_uri(query, f"sqlite:///{DB_PATH}", engine='adbc')
    overall_stats = overall_stats.with_columns(
        pl.col("date_from").str.to_datetime(format="%Y.%m.%d %H:%M:%S"),
        pl.col("date_to").str.to_datetime(format="%Y.%m.%d %H:%M:%S"),
        pl.col("overall_stats").str.json_decode(),
    )
    total_count_query = "select count(*) from model_stats_view where is_optimization = 1"
    total_count = pl.read_database_uri(total_count_query, f"sqlite:///{DB_PATH}", engine='adbc')
    total_count = total_count[total_count.columns[0]][0]
    response = {
        'data': overall_stats.to_dicts(),
        'total': total_count,
    }
    return Response(content=orjson.dumps(response), media_type="application/json")
