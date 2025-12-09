from fastapi import APIRouter
from app.backend.schemas import HealthCheck
from app.core.utils import now_utc

router = APIRouter()

@router.get("/", response_model=HealthCheck)
def health_check():
    return HealthCheck(status="ok", timestamp=now_utc())
