import logging

from fastapi import FastAPI
from sqlalchemy.ext.asyncio import create_async_engine

from mt4_backend.database import DatabaseManager
from mt4_backend.calculations import calculate_stats

logger = logging.getLogger('fastapi')
logger.setLevel(logging.DEBUG)

app = FastAPI()

DB_PATH = r"C:\Users\decim\AppData\Roaming\MetaQuotes\Terminal\3ECBA7B376E7B0171B098071238161DA\MQL4\Files\mt4_backtests.db"
db = DatabaseManager(DB_PATH)


async def process_backtests():
    unprocessed_bts = await db.get_unprocessed()
    for backtest in unprocessed_bts:
        strategy_id = await db.get_or_create_strategy(backtest["strategy_name"])
        backtest_id = await db.get_or_create_backtest(strategy_id, backtest)
        logger.info(f"Processing backtest {backtest_id} for strategy {strategy_id}")
        positions = await db.get_positions(backtest["bt_raw_id"])

        stats = calculate_stats(backtest, positions)
        # await db.save_stats(backtest_id, stats)


@app.on_event("startup")
async def startup_event():
    await db.connect_db()
    await process_backtests()


@app.on_event("shutdown")
async def shutdown_event():
    await db.disconnect_db()


@app.get("/")
def read_root():
    return {"Hello": "World"}
