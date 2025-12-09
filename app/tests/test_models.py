from app.core import repository
from app.core.models import Trade

def test_create_trade(db_session):
    trade_data = {
        "provider": "binance",
        "symbol": "BTC/USDT",
        "side": "buy",
        "amount": 0.1,
        "price": 50000.0,
        "status": "filled",
        "exchange_order_id": "12345"
    }
    trade = repository.save_trade(db_session, trade_data)
    assert trade.id is not None
    assert trade.symbol == "BTC/USDT"

def test_get_trades(db_session):
    trade_data = {
        "provider": "binance",
        "symbol": "BTC/USDT",
        "side": "buy",
        "amount": 0.1,
        "price": 50000.0,
        "status": "filled",
        "exchange_order_id": "12345"
    }
    repository.save_trade(db_session, trade_data)
    trades = repository.get_trades(db_session)
    assert len(trades) == 1
