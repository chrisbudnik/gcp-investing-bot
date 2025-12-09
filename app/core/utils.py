import datetime

def format_money(amount: float, currency: str = "USD") -> str:
    return f"{amount:.2f} {currency}"

def now_utc() -> datetime.datetime:
    return datetime.datetime.now(datetime.timezone.utc)
