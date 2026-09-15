from datetime import datetime, timezone

from pydantic import BaseModel, ConfigDict, Field, field_serializer, field_validator, model_validator

from app.models.event import AccessType, Category, Event


def isoformat_utc(value: datetime) -> str:
    """JSON timestamps are ISO 8601 in UTC, e.g. 2026-09-14T18:00:00Z."""
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def ensure_aware(value: datetime) -> datetime:
    if value.tzinfo is None:
        # Naive values from clients are treated as UTC so phones/backends agree.
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


class EventCreate(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=2000)
    category: Category
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    locationName: str = Field(min_length=1, max_length=120)
    room: str | None = Field(default=None, max_length=40)
    floor: str | None = Field(default=None, max_length=40)
    locationDetails: str | None = Field(default=None, max_length=2000)
    startsAt: datetime
    endsAt: datetime
    accessType: AccessType = AccessType.open

    @field_validator("startsAt", "endsAt")
    @classmethod
    def timestamps_are_aware(cls, value: datetime) -> datetime:
        return ensure_aware(value)

    @model_validator(mode="after")
    def end_after_start(self) -> "EventCreate":
        if self.endsAt <= self.startsAt:
            raise ValueError("End time must be after start time.")
        return self


class EventOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    description: str | None
    category: Category
    latitude: float
    longitude: float
    locationName: str
    room: str | None
    floor: str | None
    locationDetails: str | None
    startsAt: datetime
    endsAt: datetime
    accessType: AccessType
    createdAt: datetime
    updatedAt: datetime
    status: str
    distanceMiles: float | None = None

    @field_serializer("startsAt", "endsAt", "createdAt", "updatedAt")
    def serialize_datetime(self, value: datetime) -> str:
        return isoformat_utc(value)

    @classmethod
    def from_event(
        cls, event: Event, now: datetime, distance_miles: float | None = None
    ) -> "EventOut":
        return cls(
            id=event.id,
            title=event.title,
            description=event.description,
            category=event.category,
            latitude=event.latitude,
            longitude=event.longitude,
            locationName=event.location_name,
            room=event.room,
            floor=event.floor,
            locationDetails=event.location_details,
            startsAt=event.starts_at,
            endsAt=event.ends_at,
            accessType=event.access_type,
            createdAt=event.created_at,
            updatedAt=event.updated_at,
            status=status_for(event, now),
            distanceMiles=distance_miles,
        )


def status_for(event: Event, now: datetime) -> str:
    starts = ensure_aware(event.starts_at)
    ends = ensure_aware(event.ends_at)
    if now < starts:
        return "upcoming"
    if starts <= now < ends:
        return "happeningNow"
    return "ended"
