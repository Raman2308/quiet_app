# Quiet App – Project Context for AI Assistants

This file provides context for AI assistants contributing to Quiet App.
Before generating code, the assistant must first understand the project architecture.

---

# 1. Project Goal

Quiet App is a Flutter application designed with Clean Architecture principles to ensure:

• modular design
• scalable features
• testable business logic
• clear separation of responsibilities

The system prioritizes maintainability and consistent architecture.

---

# 2. Architecture Overview

Quiet App follows Clean Architecture.

Layer order:

Presentation → Domain → Data → Datasource

Rules:

• UI must not access Firebase directly
• Business logic must exist in UseCases
• Repository pattern must abstract data access
• External systems must be accessed through Datasources

---

# 3. Feature-Based Structure

Features are organized by domain functionality.

Example structure:

lib/features/

auth/
presentation/
domain/
data/

Each feature must contain its own layers.

AI assistants must always create new code within the appropriate feature module.

---

# 4. Error Handling Strategy

The application uses Failure abstraction instead of throwing exceptions.

All repository calls must return:

Future<Either<Failure, Result>>

Failure types include:

ValidationFailure
NetworkFailure
ServerFailure
AuthFailure

The UI layer must not receive raw exceptions.

---

# 5. Logging Strategy

All logging must go through a Logger abstraction.

Example interface:

abstract class Logger {
void log(String message);
void error(Object error, StackTrace stackTrace);
}

Do not use print() for logging.

---

# 6. Authentication System

Authentication is handled through Firebase.

Signup flow:

User submits signup form
↓

Controller validates inputs

↓

SignupUseCase executes

↓

AuthRepository.signup()

↓

AuthRemoteDatasource communicates with Firebase

↓

Firebase returns authentication token

---

# 7. Coding Guidelines

When generating code for this project:

• follow the existing folder structure
• keep classes small and single-purpose
• avoid mixing UI and business logic
• respect Clean Architecture boundaries
• implement repository contracts before implementation

---

# 8. AI Workflow Requirement

Before generating any new code, the AI assistant must:

1. Analyze the repository structure
2. Identify relevant modules
3. Check existing patterns in similar features
4. Follow the architecture described in docs

---

# 9. Example AI Workflow

When asked to implement a feature, the AI should first:

Analyze existing feature structure

↓

Identify presentation/domain/data layers

↓

Create necessary entities and contracts

↓

Implement datasource and repository

↓

Connect to UI layer

---

# 10. Example Prompt

Developers can use prompts like:

"Analyze the Quiet App repository and explain the architecture before implementing the signup feature."

or

"Using the architecture described in project_context.md, implement the signup feature."

---

# 11. Goal of This Document

This document ensures that AI assistants:

• understand project architecture
• follow existing patterns
• generate consistent code
• avoid architectural violations

This file acts as the **AI onboarding guide for the Quiet App codebase**.
