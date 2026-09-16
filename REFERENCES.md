# CampusPulse — assignment notes and annotated references

Use this file as source material for the Canvas PDF. Edit the name if needed.

**Name:** Jad Bardawil  
**Repository:** https://github.com/jmbgat/mobileApp  
**Course:** CS-4261 / CS-8803 Mobile Applications and Services  
**Assignment:** First Programming Assignment

## What I built

CampusPulse is a native iPhone app plus a FastAPI backend. Students post short-lived campus activities (free food, pickup sports, club tables, talks, giveaways). Other students see those posts in a **Home feed** and on a **Map**.

The app distinguishes two kinds of location:

- **Map location** (latitude / longitude) for pins and distance.
- **Human-readable location** (building, room, floor, extra directions) so GPS can get you to CULC and the text can get you to Room 144.

Tabs: Home (filterable feed), Map (clustered pins, same filters), Post (create an event), Saved (local bookmarks). Posting supports Apple Maps search, dropping a pin on a map, listed Georgia Tech landmarks, or current GPS. The backend stores events and simple activity logs (`app_open`, `event_viewed`, `event_created`, `map_pin_opened`, `filter_changed`) over REST. Ended events stay in the database but are hidden from the default feed.

## Why I built this / what I hoped to learn

I wanted a project that forced me through the whole course loop, not a toy button demo: Xcode on a real device, SwiftUI, MapKit, Core Location, a REST backend, GitHub with a partner, and documenting things that broke.

I hoped to learn:

- SwiftUI navigation, forms, and MapKit
- Core Location permissions that do not brick the app if denied
- FastAPI + SQLite and ISO-8601 dates between phone and server
- How to debug Xcode, uvicorn, and Git instead of rewriting everything
- How to work with another student through a shared repository

I used Cursor as a virtual teammate for scaffolding and debugging. I ran the app, chose the product (campus events, room/floor vs GPS), and I am responsible for explaining the code.

---

## Annotated references (in the order I used them)

### 1. Setup — environment and tools§

- **[Xcode](https://developer.apple.com/xcode/)** — Installed Xcode 16 and used it as the iOS IDE. Learned scheme/signing basics and that SwiftUI Previews are not the same as Run.
- **[Running your app in Simulator or on a device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)** — How to pick a simulator vs a physical iPhone. Learned Developer Mode and trusting a development certificate matter on a real phone.
- **[Git documentation](https://git-scm.com/doc)** — `init`, commits, `remote`, `push`, `pull`. Learned a GitHub remote is separate from having commits locally.
- **[GitHub docs](https://docs.github.com/en)** — Created https://github.com/jmbgat/mobileApp and pushed `main`. First push to github.gatech.edu failed (no HTTPS credentials in Cursor). github.com “repository not found” happened before I was logged in to a private repo.
- **[Homebrew](https://brew.sh/) / [GitHub CLI](https://cli.github.com/)** — Installed `gh` to talk to GitHub from the terminal. Still had to run `gh auth login` myself because the agent cannot type my password.

### 2. Prompt / AI assistance 

- **Cursor (Grok 4.6 and related agent tools)** — Virtual teammate for this assignment. I described CampusPulse, asked for incremental phases, and used the agent to generate project structure, FastAPI event/activity endpoints, SwiftUI screens, MapKit clustering, and README text. I also used it to diagnose build/preview errors, uvicorn `/docs` hangs, and Git remotes.

  **What it did:** wrote most of the starter and feature code; explained likely causes before changing files; suggested partner-sized tasks.

  **What I did:** ran Xcode and uvicorn, tested on Simulator, chose product rules (do not invent coordinates; room/floor are separate from the pin), decided Apple Maps search instead of Google (no API key).

  **What I learned:** AI is fast at scaffolding and good at naming a specific error, but it can generate a hand-written Xcode project that compiles from the command line while Canvas Previews fail, hang a Python server under `--reload`, or skip hosting. I treated it like a teammate I have to review, not like an oracle.

### 3. Code — iOS

- **[SwiftUI](https://developer.apple.com/documentation/swiftui)** — `TabView`, `Form`, `NavigationStack`, sheets, `ShareLink`. Learned to keep screens in Views/ and shared state in `EventStore`.
- **[URLSession](https://developer.apple.com/documentation/foundation/urlsession)** + **[Codable](https://developer.apple.com/documentation/swift/codable)** — REST client with async/await. Learned ISO-8601 decoding must allow fractional seconds because FastAPI emits them.
- **[Core Location — requesting authorization](https://developer.apple.com/documentation/corelocation/requesting-authorization-to-use-location-services)** — When-In-Use only. Learned the app must still show the feed if the user hits Don’t Allow.
- **[Information Property List](https://developer.apple.com/documentation/bundleresources/information-property-list)** — `NSLocationWhenInUseUsageDescription` and `NSAllowsLocalNetworking` so Simulator HTTP to localhost works.
- **[MapKit](https://developer.apple.com/documentation/mapkit)** — Map screen, create-event pin picker, Apple Maps search (`MKLocalSearch`), reverse geocoding (`CLGeocoder`). Chose Apple instead of Google so we did not need a billed Maps API key.
- **[MKClusterAnnotation](https://developer.apple.com/documentation/mapkit/mkclusterannotation)** / `MKMapView` clustering — When two events share a place, or pins get close on zoom-out, they merge into a numbered pin. Tap opens a swipeable pager. Learned SwiftUI `Map` + `Marker` stacks pins on top of each other, so we used `MKMapView` for clustering.
- **[ISO 8601 date formatter](https://developer.apple.com/documentation/foundation/iso8601dateformatter)** — Phone shows times in the user’s local zone; wire format is UTC with `Z`.

### 4. Code — backend

- **[FastAPI](https://fastapi.tiangolo.com/)** — `GET /health`, `POST/GET /events`, `GET /events/{id}`, `POST/GET /activity`, built-in `/docs`. Learned Pydantic validation can return “End time must be after start time.”
- **[Uvicorn](https://www.uvicorn.org/)** — How we run the API locally. Learned **not** to use `--reload` on Python 3.14 for this project (`/docs` hung while `/health` still answered).
- **[SQLAlchemy](https://docs.sqlalchemy.org/)** — SQLite `events` and `activity` tables. Learned `Base.metadata.create_all()` does nothing useful until the model classes are imported.

### 5. Debug — problems we actually hit

| Problem | What we used / learned |
| --- | --- |
| SwiftUI Preview: “Active scheme does not build this file” | Command-line `xcodebuild` still succeeded. The first `.pbxproj` was hand-written in an older style. Xcode 16 Previews wanted a folder-synced project. **Do not trust Canvas; use Run.** |
| `sqlite3.OperationalError: no such table: events` | FastAPI docs + SQLAlchemy metadata. `create_all` ran before `Event` was imported. `init_db()` now imports models first. |
| `/docs` spinner / timeout | Uvicorn logs: `--reload` worker was wedged. Restart without `--reload`. Worth a screenshot. |
| Browser `http://127.0.0.1:8000/` returned 404 | FastAPI has no homepage by default. We redirect `/` → `/docs`. |
| Map showed me in San Francisco | Simulator default fake GPS, not a bug in our coordinates. Features → Location → Custom Location (`33.77473, -84.39728`) or `GeorgiaTech.gpx`. |
| Duplicate `Info.plist` copy-bundle error | Xcode 16 synchronized folders copy `Info.plist` unless it is in a membership exception. |
| Git push `could not read Username` / `Repository not found` | Cursor cannot store my GitHub password. I had to `gh auth login` and push from Terminal. Private repos look like 404 when you are logged out. |

No tutorial was copied as the app. Code that looks like Apple/FastAPI samples was adapted, not pasted as a complete sample project.

### 6. Build, deploy, test

- **`xcodebuild`** (Xcode command-line tools) — Confirmed the iOS target compiled for iPhone 16 Simulator after each feature.
- **Simulator** — Home feed, Post form, Map clustering, filters. Not a substitute for a physical iPhone screenshot.
- **FastAPI `/docs` (Swagger UI)** — Manual tests of `GET /events`, `POST /events`, `GET /activity`.
- **curl** — `GET /health` during setup.
- **Hosting (not done yet)** — Render / Railway docs will go here after a public HTTPS URL exists. Until then the API is local SQLite via uvicorn.

### 7. Partner collaboration

My partner, Carl Fakhir, and I agreed on a small change that was useful but isolated enough to avoid conflicts: improving the time shown on event cards. He worked on the branch `feature/show-start-time-for-upcoming-events` and changed upcoming events to show their start time, while events already happening continue to show their end time. After he pushed commit `023e9fb`, I reviewed the change and merged his branch into `main`. We coordinated informally by deciding the feature and branch responsibilities before editing. I learned that agreeing on a narrow task and using a separate branch makes collaboration much easier. Next time, I would create a GitHub issue and pull request first so our discussion, review, and testing evidence are recorded in one place.

---

## Screenshot checklist (for the PDF)

See the chat notes: **now** vs **later**. Paste captions under each image in the PDF, not just the image.
