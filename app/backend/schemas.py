from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime

class TradeRead(BaseModel):
    id: int
    provider: str
    symbol: str
    side: str
    amount: float
    price: float
    status: str
    executed_at: datetime
    
    class Config:
        from_attributes = True

class PositionRead(BaseModel):
    symbol: str
    size: float
    avg_price: float
    updated_at: datetime

    class Config:
        from_attributes = True

class HealthCheck(BaseModel):
    status: str
    timestamp: datetime
