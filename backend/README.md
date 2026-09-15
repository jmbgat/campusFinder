# CampusPulse Backend

FastAPI service that the iOS app will call over REST.

## Current status (Phase 1)

- `GET /health`
- `POST /events` create an event
- `GET /events` list active/upcoming events (ended events excluded unless `includeEnded=true`)
- `GET /events/{id}` fetch one event
- SQLite database at `backend/campuspulse.db` (gitignored)
- Demo seed events around Georgia Tech if the database is empty

Useful query parameters on `GET /events`:

- `category` (`giveaway`, `sports`, `club`, …)
- `accessType` (`open`, `registrationRequired`, `membersOnly`)
- `includeEnded=true` to include expired events (they are stored, not deleted)
- `lat`, `lon`, `radiusMiles`
- `sort=soonest|newest|closest` (`closest` needs lat/lon)

## Local run

From this directory:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 127.0.0.1 --port 8000

# Avoid --reload on Python 3.14 for now; it can hang /docs in the browser.
```

Then open:

- Health: http://127.0.0.1:8000/health
- Swagger UI: http://127.0.0.1:8000/docs

A physical iPhone cannot use `localhost` on your Mac for the final demo. We will deploy this service before multi-device testing.

## Database plan

- Phase 1 local development: SQLite
- Multi-device demo: hosted PostgreSQL behind the same FastAPI app
