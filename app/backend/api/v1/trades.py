from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.core import repository
from app.backend.schemas import TradeRead

router = APIRouter()

@router.get("/", response_model=List[TradeRead])
def read_trades(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    trades = repository.get_trades(db, limit=limit, offset=skip)
    return trades
