# CampusPulse

See what’s happening around campus. Right now.

CampusPulse is a native iOS app plus a FastAPI backend for Georgia Tech CS-4261 / CS-8803. Students post short-lived campus activities (free food, pickup sports, club tables, talks). Other students see those activities on a map and in a feed, with enough human-readable location detail to find the event after GPS gets them to the building.

**Current development phase: core iOS + local FastAPI (hosted backend still TODO)**

Home, Map, Post, Saved, location, filters, and activity logging talk to the FastAPI backend. A physical iPhone still needs your Mac’s LAN IP or a hosted HTTPS URL in `APIConfig.swift`.

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
uvicorn app.main:app --host 127.0.0.1 --port 8000
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

Edit one file: `ios/CampusPulse/Services/APIConfig.swift`.

- **Simulator:** keep `http://127.0.0.1:8000` and run uvicorn on your Mac first.
- **Physical iPhone:** `127.0.0.1` is the phone, not your Mac. Put your Mac’s Wi-Fi IP, for example `http://192.168.1.12:8000`, or later the hosted HTTPS URL.
- Local HTTP is allowed via `NSAllowsLocalNetworking` in `Info.plist`.

## How to create an event

1. Start the backend.
2. Open the **Post** tab.
3. Enter title, category, times, building/place, room/floor/details.
4. Set the map pin with **Use Current Location** or a listed campus place (CULC, CRC, …). The app will not invent coordinates.
5. Tap **Post event**. Home and Map should show it after refresh. Another device using the same backend will see it too.

## How to test multi-device user-generated content

Until the API is hosted, both devices must reach the same server URL in `APIConfig.swift`. Hosting (Render + PostgreSQL) is the remaining assignment piece.

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

## Known limitations

- Backend is still local SQLite, not hosted PostgreSQL
- Sample campus coordinates are approximate
- Saved events are local to the device (UserDefaults), not an account
- No authentication or push notifications yet
- `--reload` on uvicorn + Python 3.14 can hang `/docs`; run without it

## Partner collaboration

Safe partner changes:

- Event card wording in `EventCardView.swift`
- A category SF Symbol in `EventEnums.swift`
- Empty-state copy
- Button label on Post

## Debugging notes

- `/docs` hung while uvicorn `--reload` was wedged; `/health` still answered slowly. Restart without `--reload`.
- Visiting `/` used to 404; it now redirects to `/docs`.
- `create_all()` must import models first or SQLite has no tables.

## Debugging notes

Keep screenshots of things that fail. The course values that as much as the happy path.

## License / course use

Student assignment project. Sample events will be labeled as demo data, not real campus listings.
