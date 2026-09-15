import json
from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.activity import Activity
from app.schemas.activity import ActivityCreate, ActivityOut
from app.schemas.event import ensure_aware

router = APIRouter(prefix="/activity", tags=["activity"])

ALLOWED_TYPES = {
    "app_open",
    "event_created",
    "event_viewed",
    "map_pin_opened",
    "filter_changed",
}


@router.post("", response_model=ActivityOut, status_code=201)
def log_activity(payload: ActivityCreate, db: Session = Depends(get_db)) -> ActivityOut:
    event_type = payload.eventType.strip()
    if event_type not in ALLOWED_TYPES:
        # Still store unknown types so we can see mistakes, but keep them short.
        event_type = event_type[:64]

    created_at = payload.timestamp or datetime.now(timezone.utc)
    created_at = ensure_aware(created_at)
    metadata_json = json.dumps(payload.extra) if payload.extra else None

    row = Activity(
        event_type=event_type,
        event_id=payload.eventId,
        created_at=created_at,
        metadata_json=metadata_json,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    parsed = json.loads(row.metadata_json) if row.metadata_json else None
    return ActivityOut.from_activity(row, parsed)


@router.get("", response_model=list[ActivityOut])
def list_activity(db: Session = Depends(get_db)) -> list[ActivityOut]:
    rows = db.query(Activity).order_by(Activity.created_at.desc()).limit(50).all()
    results: list[ActivityOut] = []
    for row in rows:
        parsed = json.loads(row.metadata_json) if row.metadata_json else None
        results.append(ActivityOut.from_activity(row, parsed))
    return results
