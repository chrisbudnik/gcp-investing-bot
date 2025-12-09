import asyncio
import signal
import sys
from app.core.config import settings
from app.core.logger import get_logger
from app.core.db import get_db, SessionLocal, init_db
from app.providers.provider_factory import get_provider
from app.bot.strategies.dca import DCAStrategy
from app.core.secret_manager import bootstrap_secrets_to_env

logger = get_logger("Executor")

async def main():
    logger.info("Starting Bot Executor...")
    
    # Bootstrap secrets
    bootstrap_secrets_to_env([
        settings.BINANCE_API_KEY_SECRET_NAME,
        settings.BINANCE_SECRET_KEY_SECRET_NAME
    ])
    
    # Init DB
    init_db()

    # Setup Provider
    try:
        provider = get_provider(settings.DEFAULT_PROVIDER)
    except Exception as e:
        logger.error(f"Failed to initialize provider: {e}")
        return

    # Setup Strategy (Hardcoded DCA for now, could be dynamic)
    strategy_config = {
        "symbol": "BTC/USDT",
        "amount": 0.0001,
        "interval_seconds": 60 * 60 # 1 hour
    }
    strategy = DCAStrategy(strategy_config, provider, SessionLocal, logger=logger)
    
    await strategy.start()

    running = True
    
    def handle_signal(sig, frame):
        nonlocal running
        logger.info("Shutdown signal received")
        running = False

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    while running:
        try:
            await strategy.on_tick()
            await asyncio.sleep(settings.BOT_TICK_SECONDS)
        except Exception as e:
            logger.error(f"Error in main loop: {e}")
            await asyncio.sleep(5) # Backoff on error

    await strategy.stop()
    if hasattr(provider, 'close'):
        await provider.close()
    logger.info("Bot Executor Stopped")

if __name__ == "__main__":
    asyncio.run(main())
