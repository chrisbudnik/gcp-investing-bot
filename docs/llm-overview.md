Goal
----
Build a modular, production-ready trading bot app to run on a single GCP Compute Engine VM. The initial exchange integration is CCXT for Binance. The system must be modular to add other providers (e.g., Alpaca) and new strategies easily. The UI is out-of-scope for now. Additionally provide deploy scripts under `deploy/` that create the VM, configure the environment, and put API keys in GCP Secret Manager. Provide a Makefile to automate common tasks. Security: the VM must not expose the web UI to the public internet; use SSH only. Secrets must be stored in Secret Manager and injected on startup.

Deliverables
------------
1. A complete project skeleton in `app/` with the following folders: `core`, `bot`, `adapters`, `providers`, `backend`, `deploy`, `tests`.
2. For each module: detailed module README + docstrings.
3. A clean abstract base class for strategies and exchange provider adapters, plus an example DCA strategy implemented.
4. A `bot/executor.py` that runs as a systemd service (auto-restart) and uses the shared core libraries directly (no HTTP calls to the API).
5. A `backend` folder with a small FastAPI app (local-only binding 127.0.0.1) exposing read-only endpoints for trades, positions, and health (UI later).
6. SQLAlchemy ORM mapping for trades, positions, account snapshots. Support SQLite for first deployment but designed so switching to Postgres is simple.
7. A `deploy/` folder containing bash scripts:
   - `create_project_resources.sh` (create GCS bucket, enable APIs)
   - `create_secrets.sh` (create secrets in Secret Manager)
   - `create_vm.sh` (create VM with appropriate service account and startup-script)
   - `deploy_app.sh` (copy app to VM and restart services)
   - `backup_db.sh` (db backup to GCS)
   All `gcloud` commands should be explicit.
8. `startup-script.sh` that runs on instance creation: install python, create venv, install app, configure systemd services, pull secrets from Secret Manager and write .env (mode 600).
9. `systemd` service file(s) for the bot executor and the FastAPI backend.
10. A `Makefile` with targets: `setup`, `deploy`, `ssh`, `tunnel`, `start`, `stop`, `logs`, `backup`.
11. Unit tests for core modules and a small integration test that mocks CCXT responses.
12. Documentation (README) with instructions for local development (dev VM), how to connect via SSH tunnel to the FastAPI local-only UI, and how to rotate secrets.

Constraints & Requirements
--------------------------
- Do NOT expose the FastAPI backend to the public internet; bind it to 127.0.0.1 only. Provide an SSH-tunnel command for local access.
- Secrets MUST be stored and accessed via GCP Secret Manager. VM’s service account must be granted `roles/secretmanager.secretAccessor`.
- The bot executor must not depend on the FastAPI process. Both share the same ORM.
- Use SQLAlchemy for ORM with migrations prepared (alembic/config skeleton).
- Use `ccxt` for Binance adapter initial implementation. Make provider layer pluggable: `ProviderFactory` or DI-based registration.
- Strategies must implement an `AbstractStrategy` base class with lifecycle hooks (init, on_tick, on_candle, on_order_filled, shutdown).
- Provide a `TradeEngine` that orchestrates exchange calls, order placement and retries, rate limit handling and local deduplication (idempotency).
- Implement a simple DCA strategy as example.
- Provide `logger` config (rotating file handler) and integration with systemd logging via `journald` or files.
- Provide sensible defaults for scheduling interval (e.g., 1m tick) and make them configurable via environment variables.
- Provide a simple caching layer (optional) using a local Redis if present, but ensure the app works without Redis.
- Provide commands to create IAM roles / policies needed by the VM.
- Keep code modular and fully typed (type hints).
- Include tests using pytest and a `tests/` scaffold with fixtures for DB and mocked exchanges.

Project Layout (expected)
-------------------------
app/
├─ core/
│  ├─ __init__.py
│  ├─ config.py               # env loading, config dataclass
│  ├─ db.py                   # SQLAlchemy engine/session maker, alembic config stub
│  ├─ models.py               # SQLAlchemy models: Trade, Position, AccountSnapshot
│  ├─ repository.py           # Repo functions to read/write models
│  ├─ logger.py               # structured logger + rotating file
│  ├─ secret_manager.py       # helper to fetch secrets from GCP Secret Manager
│  └─ utils.py                # helpers (time, money formatting)
│
├─ providers/
│  ├─ __init__.py
│  ├─ base.py                 # Abstract Provider interface (place_order, fetch_balance, fetch_ohlcv)
│  ├─ ccxt_provider.py        # CCXT integration wrapper generic for exchanges
│  ├─ binance_provider.py     # Binance-specific wiring using ccxt
│  └─ provider_factory.py     # register / get provider by name
│
├─ adapters/
│  ├─ __init__.py
│  └─ rate_limiter.py         # small client-side rate limiter & retry policy
│
├─ bot/
│  ├─ __init__.py
│  ├─ strategy.py             # AbstractStrategy base class
│  ├─ strategies/
│  │   ├─ __init__.py
│  │   └─ dca.py              # example DCA strategy (config-driven)
│  ├─ trade_engine.py         # responsible for placing orders safely
│  ├─ executor.py             # systemd-run infinite loop / orchestration
│  └─ experiments.py          # experiment harness for strategy parameter sweeps
│
├─ backend/
│  ├─ __init__.py
│  ├─ main.py                 # FastAPI app (bind to 127.0.0.1)
│  ├─ api/
│  │   ├─ v1/
│  │   │   ├─ trades.py
│  │   │   ├─ positions.py
│  │   │   └─ health.py
│  ├─ schemas.py              # pydantic schemas
│  └─ deps.py                 # dependency injection (Session, provider)
│
├─ deploy/
│  ├─ create_project_resources.sh
│  ├─ create_secrets.sh
│  ├─ create_vm.sh
│  ├─ deploy_app.sh
│  ├─ startup-script.sh
│  └─ backup_db.sh
│
├─ tests/
│  ├─ conftest.py
│  ├─ test_models.py
│  ├─ test_provider_mock.py
│  └─ test_dca_strategy.py
│
├─ pyproject.toml
├─ requirements.txt
└─ Makefile

Detailed Module Descriptions & Interfaces
----------------------------------------

CORE
----
`core/config.py`
- Loads configuration from environment and optionally `.env`. Use Pydantic `BaseSettings` or dataclass.
- Config items: DB_URL, LOG_LEVEL, BOT_TICK_SECONDS, DEFAULT_PROVIDER, GCP_PROJECT, SECRET_NAMES map, SERVICE_ACCOUNT_EMAIL, INSTANCE_NAME, BACKUP_BUCKET, BINANCE_API_KEY_SECRET_NAME, BINANCE_SECRET_KEY_SECRET_NAME, USE_REDIS.

`core/db.py`
- Exports `engine`, `SessionLocal`, `Base`.
- Contains `init_db()` to create tables and a stub for alembic integration.
- Use SQLite URL default: `sqlite:///./data/trades.db` and accept `DATABASE_URL` env var.

`core/models.py`
- SQLAlchemy models with descriptive columns and indices:
  - `Trade` (id, provider, symbol, side, amount, price, status, exchange_order_id, executed_at, meta json)
  - `Position` (symbol, size, avg_price, updated_at)
  - `AccountSnapshot` (balance dict JSON, timestamp)
- Add `unique` constraints for order dedupe.

`core/repository.py`
- Functions: `save_trade(session, trade_obj)`, `get_trades(session, limit, offset)`, `update_trade(session, trade_id, **fields)`, `get_positions(session)`, `save_position(session, ...)`.

`core/secret_manager.py`
- Helper `get_secret(project_id, secret_name)` that returns secret value from GCP Secret Manager (uses google-cloud-secret-manager).
- `bootstrap_secrets_to_env([...])` writes secrets to `.env` 600 and the process uses `python-dotenv`.

`core/logger.py`
- Configure `logging` with rotating file handler and console. Use structured logs: timestamp, level, module, message.
- Expose `get_logger(name)` factory.

PROVIDERS
---------
`providers/base.py`
- `class BaseProvider(ABC):`
  - `async def fetch_balance(self) -> Dict[str, Any]`
  - `async def fetch_ohlcv(self, symbol: str, timeframe: str, since: int, limit: int) -> List`
  - `async def place_order(self, symbol: str, side: str, amount: float, price: Optional[float], type: str="market") -> Dict`
  - `async def fetch_order(self, order_id: str) -> Dict`
  - `def supports(self, capability: str) -> bool`
- Provide synchronous wrappers if desired (for now synchronous `ccxt` + sync code OK).

`providers/ccxt_provider.py`
- Generic wrapper that accepts a ccxt exchange instance and maps ccxt exceptions to consistent exceptions in code.
- Handles rate limit errors, retries, and exponential backoff.
- Normalizes order response to our `Trade` model fields.

`providers/binance_provider.py`
- Concrete implementation using ccxt.binance. Handles Binance-specific nuances (e.g., symbol formatting, margin or futures flags).
- Loads keys from `core/secret_manager.get_secret()` during initialization. Keys are injected via service account access.

`providers/provider_factory.py`
- Register providers by name and return an instance: `get_provider(name: str, **kwargs)`.

ADAPTERS
--------
`adapters/rate_limiter.py`
- Simple token-bucket or leaky-bucket for outgoing requests. `acquire()` before provider call.

BOT
---
`bot/strategy.py`
- Abstract base class:

```python
from typing import Any, Dict
class AbstractStrategy(ABC):
    def __init__(self, config: Dict, provider: BaseProvider, repository: Repository, logger=None):
        self.config = config
        self.provider = provider
        self.repo = repository
        self.logger = logger or get_logger(self.__class__.__name__)

    @abstractmethod
    def on_candle(self, candle: Dict) -> None:
        """Handle a new candle. May create signals and call trade engine via repository/trade engine."""
    @abstractmethod
    def on_tick(self) -> None:
        """Periodic tasks that run every tick (e.g., check open orders)."""
    def on_order_filled(self, order_info: Dict) -> None:
        """Callback for order filled events."""
    def start(self) -> None:
        """Optional startup hook"""
    def stop(self) -> None:
        """Optional shutdown hook"""
