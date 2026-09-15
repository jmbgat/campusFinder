import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, Float, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database.db import Base


class Category(str, enum.Enum):
    event = "event"
    sports = "sports"
    giveaway = "giveaway"
    club = "club"
    career = "career"
    social = "social"
    academic = "academic"
    other = "other"


class AccessType(str, enum.Enum):
    open = "open"
    registrationRequired = "registrationRequired"
    membersOnly = "membersOnly"


class Event(Base):
    """Campus activity. Map pins use lat/lng; room/floor/details find the event."""

    __tablename__ = "events"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    title: Mapped[str] = mapped_column(String(120), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    category: Mapped[Category] = mapped_column(
        Enum(Category, values_callable=lambda items: [item.value for item in items]),
        nullable=False,
    )
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    location_name: Mapped[str] = mapped_column(String(120), nullable=False)
    room: Mapped[str | None] = mapped_column(String(40), nullable=True)
    floor: Mapped[str | None] = mapped_column(String(40), nullable=True)
    location_details: Mapped[str | None] = mapped_column(Text, nullable=True)
    starts_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    ends_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    access_type: Mapped[AccessType] = mapped_column(
        Enum(AccessType, values_callable=lambda items: [item.value for item in items]),
        nullable=False,
        default=AccessType.open,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
