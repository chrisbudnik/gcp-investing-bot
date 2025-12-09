import time
import asyncio
from app.core.logger import get_logger

logger = get_logger(__name__)

class RateLimiter:
    def __init__(self, calls: int = 10, period: float = 1.0):
        self.calls = calls
        self.period = period
        self.timestamps = []

    async def acquire(self):
        now = time.time()
        # Remove timestamps older than the period
        self.timestamps = [t for t in self.timestamps if now - t < self.period]
        
        if len(self.timestamps) >= self.calls:
            sleep_time = self.period - (now - self.timestamps[0])
            if sleep_time > 0:
                logger.debug(f"Rate limit reached, sleeping for {sleep_time:.2f}s")
                await asyncio.sleep(sleep_time)
            # Re-check after sleeping
            return await self.acquire()
        
        self.timestamps.append(time.time())
