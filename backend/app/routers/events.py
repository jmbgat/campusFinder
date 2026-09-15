from datetime import datetime, timezone
from typing import Annotated, Literal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.event import AccessType, Category, Event
from app.schemas.event import EventCreate, EventOut
from app.services.geo import distance_miles

router = APIRouter(prefix="/events", tags=["events"])

SortOption = Literal["soonest", "newest", "closest"]


@router.post("", response_model=EventOut, status_code=status.HTTP_201_CREATED)
def create_event(payload: EventCreate, db: Session = Depends(get_db)) -> EventOut:
    now = datetime.now(timezone.utc)
    event = Event(
        title=payload.title.strip(),
        description=payload.description.strip() if payload.description else None,
        category=payload.category,
        latitude=payload.latitude,
        longitude=payload.longitude,
        location_name=payload.locationName.strip(),
        room=payload.room.strip() if payload.room else None,
        floor=payload.floor.strip() if payload.floor else None,
        location_details=payload.locationDetails.strip() if payload.locationDetails else None,
        starts_at=payload.startsAt,
        ends_at=payload.endsAt,
        access_type=payload.accessType,
        created_at=now,
        updated_at=now,
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return EventOut.from_event(event, now)


@router.get("", response_model=list[EventOut])
def list_events(
    category: Category | None = None,
    accessType: AccessType | None = None,
    includeEnded: bool = False,
    lat: Annotated[float | None, Query(ge=-90, le=90)] = None,
    lon: Annotated[float | None, Query(ge=-180, le=180)] = None,
    radiusMiles: Annotated[float | None, Query(gt=0)] = None,
    sort: SortOption = "soonest",
    db: Session = Depends(get_db),
) -> list[EventOut]:
    if (lat is None) != (lon is None):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide both lat and lon, or neither.",
        )
    if radiusMiles is not None and lat is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="radiusMiles requires lat and lon.",
        )
    if sort == "closest" and lat is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sort=closest requires lat and lon.",
        )

    now = datetime.now(timezone.utc)
    query = db.query(Event)
    if category is not None:
        query = query.filter(Event.category == category)
    if accessType is not None:
        query = query.filter(Event.access_type == accessType)
    if not includeEnded:
        query = query.filter(Event.ends_at > now)

    events = query.all()
    results: list[EventOut] = []
    for event in events:
        miles = None
        if lat is not None and lon is not None:
            miles = distance_miles(lat, lon, event.latitude, event.longitude)
            if radiusMiles is not None and miles > radiusMiles:
                continue
        results.append(EventOut.from_event(event, now, miles))

    if sort == "newest":
        results.sort(key=lambda item: item.createdAt, reverse=True)
    elif sort == "closest":
        results.sort(key=lambda item: item.distanceMiles or 0)
    else:
        results.sort(key=lambda item: item.startsAt)

    return results


@router.get("/{event_id}", response_model=EventOut)
def get_event(event_id: str, db: Session = Depends(get_db)) -> EventOut:
    event = db.get(Event, event_id)
    if event is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found.")
    now = datetime.now(timezone.utc)
    return EventOut.from_event(event, now)
