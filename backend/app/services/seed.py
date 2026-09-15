from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.models.event import AccessType, Category, Event

# Approximate Georgia Tech landmark coordinates for assignment map pins.
# These are not a surveyed campus GIS dataset — verify before treating as official.
LANDMARKS = {
    "CULC": (33.77462, -84.39632),
    "CRC": (33.77547, -84.40355),
    "Klaus": (33.77715, -84.39584),
    "Van Leer": (33.77592, -84.39708),
    "Tech Green": (33.77473, -84.39728),
}


def seed_if_empty(db: Session) -> None:
    if db.query(Event).first() is not None:
        return

    now = datetime.now(timezone.utc)
    demo = "[DEMO] Sample data for development — not a real live campus listing."

    samples = [
        Event(
            title="Free Pizza",
            description=f"{demo} Extra boxes near the entrance.",
            category=Category.giveaway,
            latitude=LANDMARKS["CULC"][0],
            longitude=LANDMARKS["CULC"][1],
            location_name="CULC",
            room="144",
            floor="1st floor",
            location_details="Enter from the Tech Green side. Tables are immediately on the left.",
            starts_at=now - timedelta(minutes=20),
            ends_at=now + timedelta(hours=1, minutes=30),
            access_type=AccessType.open,
            created_at=now,
            updated_at=now,
        ),
        Event(
            title="Pickup Basketball",
            description=f"{demo} Looking for two more players.",
            category=Category.sports,
            latitude=LANDMARKS["CRC"][0],
            longitude=LANDMARKS["CRC"][1],
            location_name="CRC",
            room="Court 2",
            floor="4th floor",
            location_details="Take the elevator to floor 4. Court 2 is on the right.",
            starts_at=now + timedelta(minutes=40),
            ends_at=now + timedelta(hours=2),
            access_type=AccessType.open,
            created_at=now,
            updated_at=now,
        ),
        Event(
            title="Robotics Demo",
            description=f"{demo} Student teams showing robots in the atrium.",
            category=Category.event,
            latitude=LANDMARKS["Van Leer"][0],
            longitude=LANDMARKS["Van Leer"][1],
            location_name="Van Leer",
            room=None,
            floor="1st floor",
            location_details="Atrium near the main doors facing Atlantic Drive.",
            starts_at=now + timedelta(hours=3),
            ends_at=now + timedelta(hours=5),
            access_type=AccessType.open,
            created_at=now,
            updated_at=now,
        ),
        Event(
            title="Club Fair Booth",
            description=f"{demo} Stop by if you want stickers and a mailing list signup.",
            category=Category.club,
            latitude=LANDMARKS["Tech Green"][0],
            longitude=LANDMARKS["Tech Green"][1],
            location_name="Tech Green",
            room=None,
            floor=None,
            location_details="Near the Campanile, next to the red tent.",
            starts_at=now - timedelta(minutes=10),
            ends_at=now + timedelta(hours=2),
            access_type=AccessType.open,
            created_at=now,
            updated_at=now,
        ),
        Event(
            title="Startup Talk",
            description=f"{demo} Informal career / networking chat.",
            category=Category.career,
            latitude=LANDMARKS["Klaus"][0],
            longitude=LANDMARKS["Klaus"][1],
            location_name="Klaus",
            room="1443",
            floor="1st floor",
            location_details="Klaus Advanced Computing Building, first-floor lecture room.",
            starts_at=now + timedelta(days=1, hours=2),
            ends_at=now + timedelta(days=1, hours=3, minutes=30),
            access_type=AccessType.registrationRequired,
            created_at=now,
            updated_at=now,
        ),
    ]

    db.add_all(samples)
    db.commit()
