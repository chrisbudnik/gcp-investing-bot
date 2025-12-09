from fastapi import FastAPI
from app.backend.api.v1 import trades, positions, health
from app.core.db import init_db

app = FastAPI(title="Trading Bot API")

# Initialize DB on startup (for simplicity, usually done via migration)
@app.on_event("startup")
def on_startup():
    init_db()

app.include_router(trades.router, prefix="/api/v1/trades", tags=["trades"])
app.include_router(positions.router, prefix="/api/v1/positions", tags=["positions"])
app.include_router(health.router, prefix="/api/v1/health", tags=["health"])

if __name__ == "__main__":
    import uvicorn
    # Bind to localhost ONLY
    uvicorn.run(app, host="127.0.0.1", port=8000)
