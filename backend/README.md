# CampusPulse Backend

FastAPI service that the iOS app will call over REST.

## Current status (Phase 0)

Only `GET /health` exists. Event storage, filters, and activity logging come in later phases.

## Local run

From this directory:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then open:

- Health: http://127.0.0.1:8000/health
- Swagger UI: http://127.0.0.1:8000/docs

A physical iPhone cannot use `localhost` on your Mac for the final demo. We will deploy this service (likely Render) before multi-device testing.

## Database plan

- Phase 1 local development: SQLite (simple, no extra account)
- Multi-device demo: hosted PostgreSQL behind the same FastAPI app
