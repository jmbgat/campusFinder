# CampusPulse

See what’s happening around campus. Right now.

CampusPulse is a native iOS app plus a FastAPI backend for Georgia Tech CS-4261 / CS-8803. Students post short-lived campus activities (free food, pickup sports, club tables, talks). Other students see those activities on a map and in a feed, with enough human-readable location detail to find the event after GPS gets them to the building.

**Current development phase: Phase 0 (environment + skeletons)**

This repository is intentionally incomplete. Feed, map pins, posting, and persistence are not implemented yet.

## Why this project exists

The course assignment asks for a working mobile + backend demo, source control, partner collaboration, and a physical-device run. I am using this project to learn:

- SwiftUI navigation and forms
- MapKit and Core Location
- REST APIs with URLSession and async/await
- FastAPI + a real database
- Git collaboration with another student
- Deploying a backend that phones can reach (not localhost)

## Architecture (planned)

```
iPhone (SwiftUI)
    REST / JSON
FastAPI
    SQLAlchemy
SQLite (local) → PostgreSQL (hosted demo)
```

## Tech stack

| Layer | Choice | Why |
| --- | --- | --- |
| iOS | Swift, SwiftUI, Xcode 16, iOS 17+ | Native, matches the assignment, MapKit/Core Location are first-party |
| Networking | URLSession + Codable | No extra iOS libraries |
| Backend | Python FastAPI | Simple REST, built-in `/docs` |
| Local DB | SQLite | Fast to start in Phase 1 |
| Hosted DB | PostgreSQL (Render or similar) | Shared by multiple phones |
| Hosting | Render (or Railway if Render is painful) | HTTPS URL a real iPhone can call |

## Repository layout

```
CampusPulse/
  README.md
  REFERENCES.md
  ios/                      # Xcode project — open this
    CampusPulse.xcodeproj
    CampusPulse/
  backend/
    app/main.py
    requirements.txt
```

## iOS setup

1. Install Xcode 16 from the Mac App Store if needed.
2. Clone this repo.
3. Open `ios/CampusPulse.xcodeproj` in Xcode.
4. Select the **CampusPulse** scheme and an iPhone destination.
5. Sign the app (required for a physical device):
   - Xcode → Settings → Accounts → add your Apple ID
   - Select the CampusPulse target → Signing & Capabilities
   - Enable **Automatically manage signing**
   - Choose your Personal Team
   - If the bundle id `edu.gatech.campuspulse` is taken, change it to something unique such as `edu.gatech.campuspulse.YOURGTUSERNAME`

Minimum iOS: **17.0**. The project targets iPhone only.

### Location permission (already configured)

Xcode generate-Info.plist includes:

`NSLocationWhenInUseUsageDescription` =  
“CampusPulse uses your location to show events and activities happening near you.”

We are **not** requesting Always location. When-In-Use is enough for nearby events.

## Backend setup

See `backend/README.md`. Short version:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Health check: http://127.0.0.1:8000/health  
Swagger: http://127.0.0.1:8000/docs

## How to run on a real iPhone

1. Plug in the iPhone and unlock it. Trust the computer if asked.
2. On the phone: Settings → Privacy & Security → Developer Mode → On (iOS 16+).
3. In Xcode, choose your iPhone as the run destination (not a simulator).
4. Press Run. The first time, the phone may say “Untrusted Developer”:
   Settings → General → VPN & Device Management → trust your Apple ID.
5. The app should launch with Home / Map / Post / Saved tabs.

A free Apple ID Personal Team is enough for class. You do **not** need App Store distribution.

**Limitation found in Phase 0:** this Mac currently has no code-signing identities until you sign in to Xcode with an Apple ID. Do that before the physical-device demo.

## API configuration

Not wired yet. In a later phase there will be one `APIConfig` (or similar) file with:

- local development URL
- deployed HTTPS URL

A physical iPhone cannot use `http://127.0.0.1` on your Mac unless you set up extra networking. The graded multi-device demo should use a hosted HTTPS backend.

## Partner collaboration (preview)

Another student should be able to:

1. Clone the repo
2. Open `ios/CampusPulse.xcodeproj`
3. Select their signing team
4. Build and run
5. Make a **small, safe** change, for example:
   - change the Home placeholder wording
   - change a tab title
   - add an SF Symbol
6. Commit, push
7. You pull and run their change on your phone

Do not have the partner rewrite architecture.

## Known limitations (Phase 0)

- No events, no map pins, no posting, no database
- Backend is local-only
- App icon is the default empty asset
- GitHub remote depends on `gh` authentication (see setup notes in chat)

## Future phases

1. Event model + REST + SQLite  
2. iOS feed + API client  
3. Create event form  
4. Core Location  
5. MapKit  
6. Building/room details  
7. Filters  
8. Hosted backend + two-device test  
9. Activity logging  
10. Polish / README screenshots  
11. Optional auth / notifications only if the above works

## Debugging notes

Keep screenshots of things that fail. The course values that as much as the happy path.

## License / course use

Student assignment project. Sample events will be labeled as demo data, not real campus listings.
