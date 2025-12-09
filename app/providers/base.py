from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional

class BaseProvider(ABC):
    @abstractmethod
    async def fetch_balance(self) -> Dict[str, Any]:
        pass

    @abstractmethod
    async def fetch_ohlcv(self, symbol: str, timeframe: str, since: int = None, limit: int = 100) -> List:
        pass

    @abstractmethod
    async def place_order(self, symbol: str, side: str, amount: float, price: Optional[float] = None, type: str = "market") -> Dict:
        pass

    @abstractmethod
    async def fetch_order(self, order_id: str, symbol: str = None) -> Dict:
        pass
    
    @abstractmethod
    def supports(self, capability: str) -> bool:
        pass
