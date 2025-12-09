import ccxt.async_support as ccxt
from app.providers.base import BaseProvider
from app.core.logger import get_logger
from app.adapters.rate_limiter import RateLimiter
from typing import Dict, Any, List, Optional
import asyncio

logger = get_logger(__name__)

class CCXTProvider(BaseProvider):
    def __init__(self, exchange_id: str, api_key: str = None, secret: str = None, config: Dict = None):
        self.exchange_id = exchange_id
        exchange_class = getattr(ccxt, exchange_id)
        self.exchange = exchange_class({
            'apiKey': api_key,
            'secret': secret,
            'enableRateLimit': True,
            **(config or {})
        })
        self.rate_limiter = RateLimiter(calls=10, period=1.0) # Conservative default

    async def close(self):
        await self.exchange.close()

    async def fetch_balance(self) -> Dict[str, Any]:
        await self.rate_limiter.acquire()
        try:
            return await self.exchange.fetch_balance()
        except Exception as e:
            logger.error(f"Error fetching balance: {e}")
            raise

    async def fetch_ohlcv(self, symbol: str, timeframe: str, since: int = None, limit: int = 100) -> List:
        await self.rate_limiter.acquire()
        try:
            return await self.exchange.fetch_ohlcv(symbol, timeframe, since, limit)
        except Exception as e:
            logger.error(f"Error fetching OHLCV: {e}")
            raise

    async def place_order(self, symbol: str, side: str, amount: float, price: Optional[float] = None, type: str = "market") -> Dict:
        await self.rate_limiter.acquire()
        try:
            return await self.exchange.create_order(symbol, type, side, amount, price)
        except Exception as e:
            logger.error(f"Error placing order: {e}")
            raise

    async def fetch_order(self, order_id: str, symbol: str = None) -> Dict:
        await self.rate_limiter.acquire()
        try:
            return await self.exchange.fetch_order(order_id, symbol)
        except Exception as e:
            logger.error(f"Error fetching order: {e}")
            raise

    def supports(self, capability: str) -> bool:
        return self.exchange.has.get(capability, False)
