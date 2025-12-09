from app.providers.ccxt_provider import CCXTProvider
from app.core.config import settings
from typing import Dict

class BinanceProvider(CCXTProvider):
    def __init__(self, api_key: str = None, secret: str = None):
        config = {
            'options': {
                'defaultType': 'spot', 
            }
        }
        # Use provided keys or fall back to settings
        key = api_key or settings.BINANCE_API_KEY
        sec = secret or settings.BINANCE_SECRET_KEY
        
        super().__init__('binance', key, sec, config)
