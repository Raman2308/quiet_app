# Quiet App – AI Developer Guide

This document provides architectural and product knowledge for AI assistants (such as Continue) contributing to the Quiet App project.

The goal is to ensure that generated code follows the project’s architecture, error handling strategy, and design principles.

---

# 1. Project Overview

Quiet App is built using **Clean Architecture principles** with strong separation between UI, domain logic, and infrastructure.

The project is designed to be:

* maintainable
* testable
* modular
* scalable

Core principles:

* Separation of concerns
* Dependency inversion
* Failure abstraction
* Repository pattern
* Injectable infrastructure services

---

# 2. Architecture Layers

The application follows this architecture:

Presentation → Domain → Data → Datasource

### Presentation Layer

Responsibilities:

* UI widgets
* controllers
* state management
* form validation

Rules:

* must NOT access Firebase directly
* must NOT contain business logic
* must call **UseCases**

---

### Domain Layer

Responsibilities:

* business logic
* entities
* repository contracts
* use cases

This layer must be **framework independent**.

It must NOT depend on:

* Firebase
* UI frameworks
* networking libraries

---

### Data Layer

Responsibilities:

* repository implementations
* mapping data models
* converting datasource responses into domain objects

This layer connects **domain contracts** to **datasources**.

---

### Datasource Layer

Responsibilities:

* external systems
* Firebase
* API calls
* database access

Examples:

* FirebaseAuth
* Firestore
* REST APIs

---

# 3. Feature-Based Folder Structure

Features should be organized like this:

lib/features/

Each feature should contain its own layers.

Example:

lib/features/auth/

```
presentation/
    pages/
    controllers/

domain/
    entities/
    repositories/
    usecases/

data/
    repositories/
    datasources/
```

---

# 4. Authentication Feature Architecture

Authentication functionality belongs to:

lib/features/auth/

Expected structure:

auth/

```
presentation/
    pages/
        signup_page.dart
        login_page.dart

    controllers/
        signup_controller.dart

domain/
    entities/
        user.dart

    repositories/
        auth_repository.dart

    usecases/
        signup_user.dart
        login_user.dart

data/
    repositories/
        auth_repository_impl.dart

    datasources/
        auth_remote_datasource.dart
```

---

# 5. Signup Flow

Signup process should follow this flow:

User submits signup form

↓

SignupController validates input

↓

SignupUseCase executes business logic

↓

AuthRepository.signup()

↓

AuthRemoteDatasource creates user in Firebase

↓

Firebase returns authentication token

↓

User session created

---

# 6. Failure Abstraction

This project uses **Failure objects instead of exceptions**.

All repository calls must return:

Future<Either<Failure, Result>>

Example Failures:

ValidationFailure
NetworkFailure
ServerFailure
AuthFailure

Example usage:

result.fold(
(failure) => handleError(failure),
(success) => proceed(success)
)

UI must **never receive raw exceptions**.

---

# 7. Logging Strategy

Logging must go through the Logger abstraction.

Example interface:

abstract class Logger {
void log(String message);
void error(Object error, StackTrace stackTrace);
}

Possible implementations:

FirebaseLogger
ConsoleLogger
CrashlyticsLogger

Do not use print() directly.

---

# 8. Dependency Injection

Dependencies must be created in a central location.

Example:

main.dart or dependency injection module.

Example:

final authDatasource = AuthRemoteDatasource(firebaseAuth, logger);

final authRepository = AuthRepositoryImpl(authDatasource);

final signupUseCase = SignupUser(authRepository);

Avoid global static singletons.

---

# 9. Token & Authentication Strategy

Authentication uses **Firebase Auth tokens**.

Signup flow:

User creates account
↓

Firebase issues ID token
↓

Token stored locally for session

Future improvements may include:

refresh tokens
session expiration
role-based authorization

---

# 10. Security Rules

Signup must enforce:

• email validation
• strong password rules
• protection against duplicate accounts
• secure password handling

Never store plain text passwords.

Authentication should rely on Firebase Auth where possible.

---

# 11. Testing Strategy

The project uses **Playwright for end-to-end tests**.

Signup tests should cover:

Happy path
Duplicate email
Weak password
Network failure

Example test flow:

open signup page

enter email

enter password

submit form

expect success response

---

# 12. Coding Guidelines

AI assistants must follow these rules when generating code:

1. Follow Clean Architecture boundaries.
2. UI must not call Firebase directly.
3. Business logic must exist inside UseCases.
4. Repository pattern must be used for data access.
5. Failures must use Failure abstraction.
6. Logging must use Logger interface.

Avoid large monolithic classes.

Prefer small, testable components.

---

# 13. AI Contribution Guidelines

When generating code for this project:

• respect the feature folder structure
• implement repository contracts before implementation
• keep business logic inside UseCases
• return Either<Failure, Success> from repository methods

If uncertain, ask for clarification instead of inventing architecture.

---

# 14. Example Prompt for AI Assistants

Use prompts like:

"Implement signup flow for Quiet App following the architecture described in ai_developer_guide.md."

or

"Create SignupUseCase that calls AuthRepository.signup and returns Either<Failure, User>."

---

# 15. Goals of This Architecture

This architecture aims to provide:

* scalable codebase
* easy testing
* clear responsibility boundaries
* maintainable feature development

AI assistants should treat this document as the **source of truth** when generating code.
