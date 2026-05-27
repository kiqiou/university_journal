# University Journal (Flutter App)

Cross-platform Flutter application for managing an electronic university journal system with role-based access.

The system supports multiple user roles, academic journal management, attestation workflows, and dynamic data tables.

---

# Tech Stack

* Flutter
* Dart
* BLoC (State Management)
* HTTP (API communication)
* GetX (navigation & dependency management)
* RxDart (reactive programming)
* Syncfusion DataGrid (tables)
* Table Calendar (schedule/calendar UI)
* SharedPreferences (local storage)
* Intl (localization)
* Docker

---

# Project Overview

This application is a multi-role university journal system designed for:

* students
* teachers
* deans
* administrators

It provides role-based interfaces and dynamically adapts UI and available features depending on user permissions.

---

# Architecture

The project follows a layered architecture with BLoC pattern:

```text id="flutter-arch"
UI Layer (Screens)
        ↓
Components Layer (Widgets)
        ↓
BLoC Layer (State Management)
        ↓
Services Layer (API / Repositories)
        ↓
Data Layer (HTTP / Local Storage)
```

---

# State Management

The application uses **BLoC architecture**:

### Main blocs:

* Auth BLoC → authentication flow
* Journal BLoC → academic journal logic
* Attestation BLoC → grading and evaluation system
* Services layer → API abstraction

### Benefits:

* predictable state flow
* separation of UI and logic
* scalable multi-role architecture

---

# Project Structure

## Core structure

```bash id="flutter-structure"
lib/
├── bloc/
├── components/
├── screens/
├── shared/
├── main.dart
├── app.dart
├── app_view.dart
└── simple_bloc_observer.dart
```

---

## BLoC layer

Responsible for business logic:

```text id="bloc-layer"
bloc/
├── auth/
├── journal/
├── attestation/
└── services/
```

Handles:

* authentication state
* journal data flow
* attestation calculations
* API communication logic

---

## Screens (Role-based UI)

The application uses role-based screen separation:

```text id="screens"
screens/
├── auth/
├── admin_1/
├── admin_2/
├── dean/
├── teacher/
└── student/
```

Each role has a dedicated UI and permissions set.

---

## Shared components

Reusable logic and UI:

* journal components
* attestation components
* table themes
* utility functions

---

## UI components

* reusable widgets
* design system
* color palette
* constants

---

# Key Features

## Authentication system

* role-based login
* secure session handling
* persistent user state

---

## Journal system

* academic journal management
* disciplines and sessions tracking
* dynamic data tables

---

## Attestation system

* student performance evaluation
* grade tracking
* structured assessment logic

---

## Role-based access system

### Roles:

* Admin 1 — academic disciplines management
* Admin 2 — student & group management
* Dean — faculty overview & control
* Teacher — journal & grades management
* Student — personal academic data view

Each role loads a different UI and functionality set.

---

## UI/UX Features

* responsive Flutter UI
* adaptive role-based navigation
* calendar integration
* advanced data tables
* cached images and performance optimization

---

# Core Dependencies

## State management

* BLoC
* RxDart

## UI

* Syncfusion DataGrid
* Table Calendar
* Flutter widgets system

## Networking

* HTTP client

## Storage

* SharedPreferences

## Utilities

* Equatable (state comparison)
* Intl (localization)

---

# Localization

Supported languages:

* Russian (ru_RU)
* English (en_US)

---

# Platform Support

This is a fully cross-platform application:

* Android
* iOS
* Web
* Windows
* macOS
* Linux

---

# Technical Highlights

## 1. Role-based architecture

Each role has isolated UI and logic, improving security and maintainability.

## 2. BLoC separation

Business logic is fully separated from UI layer.

## 3. Reactive programming

RxDart used for reactive streams in state handling.

## 4. Data-heavy UI optimization

* caching
* efficient table rendering
* optimized state updates

---

# Key Functional Modules

## Journal module

* discipline tracking
* session management
* academic records

## Attestation module

* evaluation logic
* grading system
* performance tracking

## Auth module

* login system
* role assignment
* session persistence

---

# Architecture Benefits

* scalable multi-role system
* separation of concerns
* reusable components
* maintainable BLoC structure
* cross-platform consistency

---

# Docker Support

Project includes Docker configuration for environment consistency.

```bash id="flutter-docker"
docker-compose up --build
```

---

# Author

Ekaterina Kuksar
GitHub: https://github.com/kiqiou
