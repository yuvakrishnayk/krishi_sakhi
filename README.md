# ScreenShots
https://drive.google.com/file/d/1GhJ7A_urHhRps_QEJASa7BghAnWubbYC/view?usp=sharing

# Krishi Sakhi

AI-Powered Personal Farming Assistant for Kerala Farmers

Krishi Sakhi is a Malayalam-first, mobile-first digital farming companion that delivers personalized, daily, actionable guidance to farmers in Kerala using an agentic RAG (Retrieval-Augmented Generation) architecture, weather & pest APIs, and a rule-based task engine.


## Problem Statement

Farmers in Kerala face climate volatility, pest outbreaks, fragmented information systems, and low digital accessibility. These challenges cause 15–30% crop losses per season, increased input costs, and missed adoption of scientific best practices.

Core gap: No personalized, daily-action, Malayalam-first system that tells a farmer "what to do today" for their specific crop, soil, weather and risks.

## Proposed Solution

Krishi Sakhi provides personalized, actionable, real-time recommendations in Malayalam through voice and text, focused on the farmer's crop, growth stage, soil, and local weather.

### Core Features

- Smart Farm Advisory: Crop-specific, soil-aware recommendations; daily & weekly tasks; growth-stage guidance.
- Early Risk Detection: Real-time weather monitoring, pest & disease risk alerts, early warnings.
- Malayalam-First Experience: Voice + text interaction, step-by-step instructions for low digital-literacy users.
- Micro-Learning & Community: Daily 5-minute tips, learning modules, and a community forum for peer support.

### Technology Architecture (high level)

- Agentic RAG (Retrieval-Augmented Generation) for explainable localized advice
- Farmer Profiling Engine to capture crop, acreage, soil, and growth stage
- Rule-Based Task Engine to convert AI recommendations into daily actionable tasks
- Weather & Pest APIs for near real-time risk detection
- Mobile-First (Android-focused) app; lightweight & low-bandwidth UI

### Target Users

- Small & marginal farmers (< 2 hectares)
- Medium-scale farmers
- Farmer Producer Organizations (FPOs) and cooperatives
- Government extension programs

### Competitive Advantages

- Daily, growth-stage-aware tasks vs. generic chatbots
- Malayalam-first voice UX for low literacy users
- Continuous learning loop + early risk alerts

## Repo Structure (overview)

- /android, /ios, /lib, /assets — Flutter mobile app
- /server — Python backend, RAG components and APIs
- /web — Minimal web entrypoints (if any)

## Installation & Local Development

Prerequisites

- Flutter (recommended >= 3.0) installed and on PATH: https://docs.flutter.dev/get-started/install
- Android Studio or Xcode for device/emulator builds
- Python 3.10+ for the server (or use Docker)
- Git

1. Clone the repository

```bash
git clone <repo-url>
cd krishi_sakhi
```

2. Mobile app: fetch packages and run

```bash
flutter pub get
# Run on Android emulator or connected device
flutter run
```

3. Backend (local, inside /server)

Option A — Python virtualenv

```bash
cd server
python -m venv .venv
.\.venv\Scripts\activate    # Windows
source .venv/bin/activate    # macOS / Linux
pip install -r requirements.txt
export FLASK_ENV=development
python app.py
```

Option B — Docker (recommended for parity)

```bash
cd server
docker-compose up --build
```

4. Environment & API keys

- Add provider keys (weather APIs, RAG vector DB, Firebase) to environment or server/config files. See `server/README.md` (if present) or create a `.env` in `/server` with the following values as applicable:

- WEATHER_API_KEY=...
- VECTOR_DB_URL=...
- FIREBASE_CREDENTIALS=... (or place `google-services.json` in `android/app/`)

5. Run end-to-end locally

- Start backend, then run the Flutter app pointing to the backend API host (edit `lib/constants.dart` or environment configuration used by the app).

## Repo Process & Contribution Guidelines

Branching & PRs

- Branch off `main` using feature branches: `feature/<short-description>` or `fix/<short-description>`.
- Open a pull request against `main` and include a short description, testing steps, and screenshots if relevant.

Code Style & Commits

- Dart/Flutter: follow Flutter/Dart style. Run `flutter format` before committing.
- Python: follow PEP8; run `black` and `ruff` where configured.
- Commit messages: use short imperatives, e.g. "Add daily task engine".

Testing

- Mobile: unit tests under `test/` using `flutter test`.
- Server: Python tests under `server/tests` using `pytest`.

Issue Tracking

- Create issues for bugs, features, and docs. Tag with `area/mobile`, `area/server`, `priority/high` where appropriate.

Localization & Content

- ARB files are under `lib/l10n/`. Add translations and run the localization generation step if you modify them.

Security & Secrets

- Never commit API keys or credentials. Use `.gitignore` for `.env` and platform credential files.

CI / CD (suggested)

- Add GitHub Actions to run `flutter analyze`, `flutter test`, and Python `pytest` on PRs.
- Use workflow secrets to store API keys for release builds and deployment.

Releases & Play Store

- Create release tags and use a release branch for Play Store packaging. Follow Google Play signing best practices and keep keystore outside the repo.

## How to Help / First Contributions

- See Issues for beginner-friendly tasks labeled `good first issue`.
- To add a feature: discuss in an issue, branch from `main`, implement, add tests, open a PR.

## License & Attribution

- Add license file if required (e.g., MIT). This repository currently has no license file — add one before sharing publicly.

---

If you'd like, I can also add a separate `CONTRIBUTING.md`, `server/README.md` with environment examples, and a `CODE_OF_CONDUCT.md`. Tell me which of those you'd like next.
