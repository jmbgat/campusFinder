from fastapi import FastAPI

app = FastAPI(
    title="CampusPulse API",
    description="Backend for the CampusPulse iOS app. Phase 0: health check only.",
    version="0.1.0",
)


@app.get("/health")
def health() -> dict[str, str]:
    """Simple liveness check used by local setup and later by the iOS app."""
    return {"status": "ok", "service": "campuspulse"}
