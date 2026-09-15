from datetime import datetime, timezone

from pydantic import BaseModel, ConfigDict, Field, field_serializer, field_validator

from app.models.activity import Activity
from app.schemas.event import ensure_aware, isoformat_utc


class ActivityCreate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    eventType: str = Field(min_length=1, max_length=64)
    eventId: str | None = None
    timestamp: datetime | None = None
    extra: dict | None = Field(default=None, alias="metadata")

    @field_validator("timestamp")
    @classmethod
    def aware_timestamp(cls, value: datetime | None) -> datetime | None:
        return ensure_aware(value) if value is not None else None


class ActivityOut(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    eventType: str
    eventId: str | None
    timestamp: datetime
    extra: dict | None = Field(default=None, alias="metadata", serialization_alias="metadata")

    @field_serializer("timestamp")
    def serialize_timestamp(self, value: datetime) -> str:
        return isoformat_utc(value)

    @classmethod
    def from_activity(cls, row: Activity, metadata: dict | None) -> "ActivityOut":
        return cls(
            id=row.id,
            eventType=row.event_type,
            eventId=row.event_id,
            timestamp=row.created_at,
            extra=metadata,
        )
