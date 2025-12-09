from sqlalchemy import Column, Integer, String, Float, DateTime, JSON, UniqueConstraint
from sqlalchemy.sql import func
from app.core.db import Base
import datetime

class Trade(Base):
    __tablename__ = "trades"

    id = Column(Integer, primary_key=True, index=True)
    provider = Column(String, index=True)
    symbol = Column(String, index=True)
    side = Column(String)  # buy, sell
    amount = Column(Float)
    price = Column(Float)
    status = Column(String) # open, closed, filled, canceled
    exchange_order_id = Column(String, index=True)
    executed_at = Column(DateTime(timezone=True), server_default=func.now())
    meta_data = Column(JSON, nullable=True)

    __table_args__ = (
        UniqueConstraint('provider', 'exchange_order_id', name='uq_provider_order_id'),
    )

class Position(Base):
    __tablename__ = "positions"

    id = Column(Integer, primary_key=True, index=True)
    symbol = Column(String, unique=True, index=True)
    size = Column(Float)
    avg_price = Column(Float)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

class AccountSnapshot(Base):
    __tablename__ = "account_snapshots"

    id = Column(Integer, primary_key=True, index=True)
    balance = Column(JSON)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
