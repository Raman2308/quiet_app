
# Quiet App

Quiet is a cross-platform Flutter application designed with Clean Architecture principles, strong separation of concerns, and automation-first validation strategy.
A scalable Flutter application built using Clean Architecture, Firebase, and structured error handling.
This project demonstrates production-oriented engineering practices including failure abstraction, dependency injection, logging, and scalability planning.
The project demonstrates scalable structure, repository abstraction, dependency injection, and CI-driven testing workflows.

## Tech Stack
Flutter (Web + Android)
Dart
Firebase Firestore
Playwright (Web E2E testing)
GitHub Actions (CI automation)
## Engineering Principles Demonstrated

Repository Pattern
Dependency Inversion Principle
Feature-based folder structure
Environment-aware CI testing
Clean Git hygiene
Separation of concerns
Automation-first validation

## Project Goals
- Clean, scalable Flutter architecture
- Clear separation of UI, business logic, and configuration
- Cloud-only E2E testing to reduce local system load
- CI-based validation with downloadable test reports
##Architecture Overview

The application follows a feature-first clean architecture pattern:

Presentation Layer
    ↓
Domain Layer (Entities + Repository Contracts)
    ↓
Data Layer (Repository Implementation)
    ↓
Datasource Layer (Firebase)

Layer Responsibilities

Presentation → UI, state management
Domain → Business entities & abstract repository contracts
Data → Repository implementations
Datasource → External services (Firebase)

This ensures:
Database can be swapped by modifying only the datasource
UI remains independent of backend implementation
High testability through abstraction

## Run Locally

flutter pub get
flutter run

##Testing Strategy
Unit & widget tests: local
End-to-end tests (Playwright): CI only
##CI
GitHub Actions runs Playwright tests on push
HTML test reports are generated in CI
Reports are downloadable from CI artifacts
Continuous Integration

##CI pipeline includes:

Build validation
Automated E2E browser testing
Artifact-based test reporting
This ensures cloud-based validation without heavy local execution.

# Why I Used Clean Architecture

I chose Clean Architecture to achieve long-term maintainability, testability, and scalability.

## 1. Separation of Concerns

Each layer has a single responsibility:
UI → Controller → Repository → Data Source → Firebase

- **UI** handles rendering and user interaction.
- **Controllers** coordinate application logic.
- **Repositories** abstract data access.
- **Data Sources** communicate with external services.
- **Core Layer** manages errors and logging.

This ensures the system is:
- Easier to test  
- Easier to maintain  
- Easier to scale  
- Easier to refactor or replace infrastructure  

---

## 2. Dependency Rule

Dependencies always point inward.

- **UI** handles rendering and user interaction.
- **Controllers** coordinate application logic.
- **Repositories** abstract data access.
- **Data Sources** communicate with external services.
- **Core Layer** manages errors and logging.

This ensures the system is:
- Easier to test  
- Easier to maintain  
- Easier to scale  
- Easier to refactor or replace infrastructure  

---

## 2. Dependency Rule

Dependencies always point inward.
Outer layers depend on inner layers
Inner layers never depend on outer layers

For example:
- Domain does not know about Firebase.
- Logger is abstracted via interface.
- Data sources depend on abstractions, not concrete implementations.

This prevents tight coupling and architecture leakage.

---

# How Failure Flow Works

The app implements structured failure handling using layered abstraction.

## Step 1: External Error Occurs
Firebase may throw a `FirebaseException`.

## Step 2: Data Layer Converts Exception
The remote data source catches the exception and throws a custom exception:


For example:
- Domain does not know about Firebase.
- Logger is abstracted via interface.
- Data sources depend on abstractions, not concrete implementations.

This prevents tight coupling and architecture leakage.

---

# How Failure Flow Works

The app implements structured failure handling using layered abstraction.

## Step 1: External Error Occurs
Firebase may throw a `FirebaseException`.

## Step 2: Data Layer Converts Exception
The remote data source catches the exception and throws a custom exception:

FirebaseException → ServerException / NetworkException


## Step 3: Repository Maps to Failure
The repository converts exceptions into domain failures:

ServerException → ServerFailure
NetworkException → NetworkFailure

Repository returns:

Future<Either<Failure, T>>


## Step 4: UI Handles Failure
The UI folds the result:
result.fold(
(failure) => showError(failure.message),
(success) => proceed()
)


### Why This Matters

- UI never receives raw exceptions.
- Infrastructure details do not leak into presentation.
- Error handling is predictable and centralized.
- Fully testable.

---

# How Logger Works

Logging is abstracted through an interface:

```dart
abstract class Logger {
  void log(String message);
  void error(Object error, StackTrace stackTrace);
}
Firebase Implementation
class FirebaseLogger implements Logger
This allows:

Production → Firebase Crashlytics

Development → Console logger

Future → Replace with Sentry or custom backend

Why Not Static Logging?

Static logging tightly couples the system to a specific implementation and reduces testability.

Using abstraction ensures:

Dependency inversion

Replaceability

Testability

How Dependency Injection Works

Dependencies are created at the top level and injected downward.

Example in main.dart:

final logger = FirebaseLogger(FirebaseCrashlytics.instance);
final firestore = FirebaseFirestore.instance;

final adminRemoteDataSource =
    AdminRemoteDataSource(firestore: firestore, logger: logger);


Dependencies are passed through constructors rather than using global singletons.

Benefits

Clear dependency graph

Easier mocking in tests

Better modularity

Predictable lifecycle

Scalability Considerations

Although this is a portfolio project, it is designed with scalability in mind.

Current Design Supports

Pagination instead of fetching all records

Timeout handling for network safety

Structured logging

Failure abstraction

Replaceable infrastructure

Clean dependency boundaries

How It Would Evolve for Large Scale

If scaling to millions of users:

Add server-side role validation

Introduce caching layer

Add metrics tracking (latency, failure rate)

Add background processing

Implement rate limiting

Introduce feature flags for controlled rollout

The current architecture supports these upgrades without major refactoring.

Testing Strategy

The architecture enables:

Unit testing repositories (mock data sources)

Unit testing controllers (mock repositories)

Widget testing UI independently

Integration testing Firebase layer

Testability was a primary architectural requirement.

Tradeoff Decisions

This project intentionally avoids over-engineering.

Not included:

Circuit breaker pattern

Distributed tracing system

Microservice abstractions

Reason:

The goal is clarity, maintainability, and professional structure — not unnecessary complexity.

What This Project Demonstrates

Understanding of Clean Architecture

Dependency inversion principles

Structured failure handling

Logging abstraction

Scalable data access patterns

Production-oriented thinking

If discussing in an interview, I can clearly explain:

Why this architecture was chosen

How failures propagate safely

How dependencies are controlled

How the system can scale

What tradeoffs were made


---




Status
Active development.

Architecture is incrementally refined toward production-level standards, with ongoing improvements in testing, abstraction, and scalability.
