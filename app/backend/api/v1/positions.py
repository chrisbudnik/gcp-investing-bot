from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.core import repository
from app.backend.schemas import PositionRead

router = APIRouter()

@router.get("/", response_model=List[PositionRead])
def read_positions(db: Session = Depends(get_db)):
    positions = repository.get_positions(db)
    return positions
