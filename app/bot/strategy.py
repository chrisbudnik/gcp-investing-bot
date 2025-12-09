from abc import ABC, abstractmethod
from typing import Dict, Optional
from app.providers.base import BaseProvider
from app.core.logger import get_logger
from sqlalchemy.orm import Session


class AbstractStrategy(ABC):
    def __init__(self, config: Dict, provider: BaseProvider, session_factory, logger=None):
        self.config = config
        self.provider = provider
        self.session_factory = session_factory
        self.logger = logger or get_logger(self.__class__.__name__)

    @abstractmethod
    async def on_candle(self, candle: Dict) -> None:
        """Handle a new candle. May create signals and call trade engine via repository/trade engine."""
        pass

    @abstractmethod
    async def on_tick(self) -> None:
        """Periodic tasks that run every tick (e.g., check open orders)."""
        pass

    async def on_order_filled(self, order_info: Dict) -> None:
        """Callback for order filled events."""
        pass

    async def start(self) -> None:
        """Optional startup hook"""
        self.logger.info("Strategy started")

    async def stop(self) -> None:
        """Optional shutdown hook"""
        self.logger.info("Strategy stopped")
