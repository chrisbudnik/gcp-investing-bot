import pytest
from unittest.mock import MagicMock, AsyncMock
from app.providers.ccxt_provider import CCXTProvider

@pytest.mark.asyncio
async def test_ccxt_provider_fetch_balance():
    provider = CCXTProvider("binance", "key", "secret")
    
    # Mock the internal exchange object
    provider.exchange.fetch_balance = AsyncMock(return_value={"total": {"BTC": 1.0}})
    
    balance = await provider.fetch_balance()
    assert balance["total"]["BTC"] == 1.0
    
    await provider.close()

@pytest.mark.asyncio
async def test_ccxt_provider_place_order():
    provider = CCXTProvider("binance", "key", "secret")
    
    expected_response = {"id": "123", "status": "open"}
    provider.exchange.create_order = AsyncMock(return_value=expected_response)
    
    order = await provider.place_order("BTC/USDT", "buy", 0.1)
    assert order["id"] == "123"
    
    await provider.close()
