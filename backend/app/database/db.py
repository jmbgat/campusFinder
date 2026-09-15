from collections.abc import Generator
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

# SQLite file lives in backend/campuspulse.db (gitignored).
# Swap DATABASE_URL later for hosted PostgreSQL without changing the routers.
DB_PATH = Path(__file__).resolve().parent.parent.parent / "campuspulse.db"
DATABASE_URL = f"sqlite:///{DB_PATH}"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    # Import models so they register on Base.metadata before create_all.
    from app.models import activity as _activity  # noqa: F401
    from app.models import event as _event  # noqa: F401

    Base.metadata.create_all(bind=engine)
