import os
from typing import Dict, Optional
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    # General
    ENV: str = "development"
    LOG_LEVEL: str = "INFO"
    GCP_PROJECT: Optional[str] = None
    
    # Database
    DATABASE_URL: str = "sqlite:///./data/trades.db"
    
    # Bot
    BOT_TICK_SECONDS: int = 60
    DEFAULT_PROVIDER: str = "binance"
    
    # Secrets (Names in Secret Manager)
    BINANCE_API_KEY_SECRET_NAME: str = "binance_api_key"
    BINANCE_SECRET_KEY_SECRET_NAME: str = "binance_secret_key"
    
    # Loaded Secrets (populated at runtime or via env)
    BINANCE_API_KEY: Optional[str] = None
    BINANCE_SECRET_KEY: Optional[str] = None
    
    # Backup
    BACKUP_BUCKET: Optional[str] = None
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
