
# Quiet App

Quiet is a Flutter-based cross-platform application focused on clean architecture,
testability, and automation-first validation.

## Tech Stack
- Flutter (Web + Android)
- Dart
- Playwright (for web E2E testing)
- GitHub Actions (CI)

## Project Goals
- Clean, scalable Flutter architecture
- Clear separation of UI, business logic, and configuration
- Cloud-only E2E testing to reduce local system load
- CI-based validation with downloadable test reports

## Run Locally
```bash
flutter pub get
flutter run

Testing Strategy
•	Unit & widget tests: local
•	End-to-end tests (Playwright): CI only
CI
•	GitHub Actions runs Playwright tests on push
•	HTML test reports are generated in CI
Status
 Active development — architecture and testing pipelines are being added incrementally.
