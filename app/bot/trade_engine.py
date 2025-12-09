from app.providers.base import BaseProvider
from app.core import repository
from app.core.logger import get_logger
from sqlalchemy.orm import Session
from typing import Dict, Optional

logger = get_logger(__name__)

class TradeEngine:
    def __init__(self, provider: BaseProvider, session_factory):
        self.provider = provider
        self.session_factory = session_factory

    async def execute_buy(self, symbol: str, amount: float, price: Optional[float] = None) -> Dict:
        logger.info(f"Executing BUY for {symbol}: {amount} @ {price or 'MARKET'}")
        
        # 1. Place order on exchange
        try:
            order = await self.provider.place_order(symbol, "buy", amount, price)
        except Exception as e:
            logger.error(f"Failed to place buy order: {e}")
            raise

        # 2. Record in DB
        with self.session_factory() as session:
            repository.save_trade(session, {
                "provider": "binance", # TODO: dynamic
                "symbol": symbol,
                "side": "buy",
                "amount": amount,
                "price": price or 0.0, # Approximate if market
                "status": order.get("status", "open"),
                "exchange_order_id": str(order["id"]),
                "meta_data": order
            })
            
            # Update position (simplified, ideally should wait for fill)
            # For now, we assume immediate fill or handle it in on_tick checks
            # But let's just record it for the example
            if order.get("status") == "closed":
                 repository.save_position(session, symbol, amount, price or 0.0)

        return order
