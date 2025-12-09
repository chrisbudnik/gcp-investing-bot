from app.providers.binance_provider import BinanceProvider
from app.providers.base import BaseProvider

def get_provider(name: str, **kwargs) -> BaseProvider:
    if name.lower() == "binance":
        return BinanceProvider(**kwargs)
    else:
        raise ValueError(f"Unknown provider: {name}")
