from sqlalchemy.orm import Session
from app.core.models import Trade, Position, AccountSnapshot
from typing import List, Optional, Dict, Any

def save_trade(session: Session, trade_data: Dict[str, Any]) -> Trade:
    trade = Trade(**trade_data)
    session.add(trade)
    session.commit()
    session.refresh(trade)
    return trade

def get_trades(session: Session, limit: int = 100, offset: int = 0) -> List[Trade]:
    return session.query(Trade).order_by(Trade.executed_at.desc()).offset(offset).limit(limit).all()

def update_trade(session: Session, trade_id: int, **kwargs) -> Optional[Trade]:
    trade = session.query(Trade).filter(Trade.id == trade_id).first()
    if trade:
        for key, value in kwargs.items():
            setattr(trade, key, value)
        session.commit()
        session.refresh(trade)
    return trade

def get_position(session: Session, symbol: str) -> Optional[Position]:
    return session.query(Position).filter(Position.symbol == symbol).first()

def get_positions(session: Session) -> List[Position]:
    return session.query(Position).all()

def save_position(session: Session, symbol: str, size: float, avg_price: float) -> Position:
    position = get_position(session, symbol)
    if not position:
        position = Position(symbol=symbol, size=size, avg_price=avg_price)
        session.add(position)
    else:
        position.size = size
        position.avg_price = avg_price
    session.commit()
    session.refresh(position)
    return position

def save_account_snapshot(session: Session, balance: Dict[str, Any]) -> AccountSnapshot:
    snapshot = AccountSnapshot(balance=balance)
    session.add(snapshot)
    session.commit()
    session.refresh(snapshot)
    return snapshot
