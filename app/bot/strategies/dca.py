from app.bot.strategy import AbstractStrategy
from app.bot.trade_engine import TradeEngine
from typing import Dict
import asyncio

class DCAStrategy(AbstractStrategy):
    def __init__(self, config: Dict, provider, session_factory, logger=None):
        super().__init__(config, provider, session_factory, logger)
        self.trade_engine = TradeEngine(provider, session_factory)
        self.symbol = config.get("symbol", "BTC/USDT")
        self.amount = config.get("amount", 0.001)
        self.interval = config.get("interval_seconds", 60)
        self.last_buy_time = 0

    async def on_tick(self) -> None:
        # Simple time-based DCA
        import time
        now = time.time()
        if now - self.last_buy_time > self.interval:
            self.logger.info(f"DCA Triggered for {self.symbol}")
            try:
                await self.trade_engine.execute_buy(self.symbol, self.amount)
                self.last_buy_time = now
            except Exception as e:
                self.logger.error(f"DCA Buy failed: {e}")

    async def on_candle(self, candle: Dict) -> None:
        pass
