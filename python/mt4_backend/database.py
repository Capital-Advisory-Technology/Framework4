import json
import logging

import aiosqlite

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('aiosqlite')


class DatabaseManager:
    def __init__(self, database_url):
        self.database_url: str = database_url
        self.db: aiosqlite.Connection | None = None

    async def connect_db(self):
        self.db = await aiosqlite.connect(self.database_url)
        self.db.row_factory = aiosqlite.Row
        await self.db.set_trace_callback(logger.info)

    async def disconnect_db(self):
        await self.db.close()

    async def get_unprocessed(self) -> list[dict]:
        query = "SELECT * FROM backtests_raw where is_processed = 0"
        async with self.db.execute(query) as cursor:
            data = await cursor.fetchall()
            return [dict(row) for row in data]

    async def get_or_create_strategy(self, strategy_name: str) -> int:
        get_query = f"SELECT strategy_id FROM strategies WHERE name = '{strategy_name}'"
        async with self.db.execute(get_query) as cursor:
            row = await cursor.fetchone()
            if row:
                return row[0]

        insert_query = f"INSERT INTO strategies (name) VALUES ('{strategy_name}')"
        async with self.db.execute(insert_query) as cursor:
            await self.db.commit()
            return cursor.lastrowid

    async def get_symbol_id(self, symbol: str) -> int:
        get_query = f"SELECT symbol_id FROM symbols WHERE name = '{symbol}'"
        async with self.db.execute(get_query) as cursor:
            row = await cursor.fetchone()
            if row:
                return row[0]
            raise ValueError("Symbol not found")

    async def get_period_id(self, period: int) -> int:
        get_query = f"SELECT period_id FROM periods WHERE value = {period}"
        async with self.db.execute(get_query) as cursor:
            row = await cursor.fetchone()
            if row:
                return row[0]
            raise ValueError("Period not found")

    async def get_or_create_backtest(self, strategy_id, backtest: dict) -> int:
        bt_raw_id = backtest["bt_raw_id"]
        symbol_id = await self.get_symbol_id(backtest["symbol"])
        period_id = await self.get_period_id(backtest["period"])
        account_currency = backtest["account_currency"]
        inputs = backtest["inputs"]

        get_query = f"SELECT * FROM backtests WHERE strategy_id = {strategy_id}"
        cursor = await self.db.execute(get_query)
        row = await cursor.fetchone()
        if row:
            return row[0]

        insert_query = (f"INSERT INTO backtests "
                        f"(strategy_id, bt_raw_id, symbol_id, period_id, account_currency, inputs) "
                        f"VALUES "
                        f"({strategy_id}, {bt_raw_id}, {symbol_id}, {period_id}, '{account_currency}', '{inputs}')")

        cursor = await self.db.execute(insert_query)
        await self.db.commit()
        return cursor.lastrowid

    async def get_positions(self, bt_raw_id: int) -> list[dict[str, any]]:
        query = f"SELECT * FROM positions WHERE bt_raw_id = {bt_raw_id}"
        async with self.db.execute(query) as cursor:
            data = await cursor.fetchall()
            data = [dict(row) for row in data]
            return data

    async def save_stats(self, bt_id: int, backtest: dict, stats: dict):
        date_from = backtest["date_from"]
        date_to = backtest["date_to"]
        is_optimization = backtest["is_optimization"]
        is_test = backtest["is_test"]
        get_query = (f"SELECT * FROM backtests_stats "
                     f"WHERE bt_id = {bt_id} AND date_from = '{date_from}' AND date_to = '{date_to}'"
                     f"AND is_optimization = {is_optimization} AND is_test = {is_test}")
        async with self.db.execute(get_query) as cursor:
            row = await cursor.fetchone()
            if row:
                return

        overall_stats = json.dumps(stats["overall"])
        yearly_stats = json.dumps(stats["yearly"])
        monthly_stats = json.dumps(stats["monthly"])

        stats_query = (f"INSERT INTO backtests_stats "
                       f"(bt_id, date_from, date_to, overall_stats, yearly_stats, monthly_stats, is_optimization, is_test) "
                       f"VALUES "
                       f"({bt_id}, '{backtest['date_from']}', '{backtest['date_to']}', '{overall_stats}', '{yearly_stats}', '{monthly_stats}', {backtest['is_optimization']}, {backtest['is_test']});")
        await self.db.execute(stats_query)

        update_query = f"UPDATE backtests_raw SET is_processed = 1 WHERE bt_raw_id = {backtest['bt_raw_id']}"
        await self.db.execute(update_query)

        await self.db.commit()
        logger.info(f"Stats for backtest {bt_id} saved.")
