from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.responses import RedirectResponse

from app.database.db import SessionLocal, init_db
from app.routers.activity import router as activity_router
from app.routers.events import router as events_router
from app.services.seed import seed_if_empty


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_db()
    db = SessionLocal()
    try:
        seed_if_empty(db)
    finally:
        db.close()
    yield


app = FastAPI(
    title="CampusPulse API",
    description="Backend for the CampusPulse iOS app.",
    version="0.2.0",
    lifespan=lifespan,
)

app.include_router(events_router)
app.include_router(activity_router)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    return RedirectResponse(url="/docs")


@app.get("/health")
def health() -> dict[str, str]:
    """Simple liveness check used by local setup and later by the iOS app."""
    return {"status": "ok", "service": "campuspulse"}
