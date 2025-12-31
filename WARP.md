# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

YouHQ is a personal life management iOS app built with Swift, SwiftUI, and SQLiteData. It organizes various aspects of life including residences, vehicles, finances, media/devices, career, and insurance into a tabbed interface backed by a SQLite database.

## Development Commands

### Building and Running
```bash
# Build the project
xcodebuild -project YouHQ.xcodeproj -scheme YouHQ -configuration Debug build

# Run on simulator (after building)
# Use Xcode or: xcrun simctl boot <device_id> && xcrun simctl install booted <path_to_app>

# Clean build folder
xcodebuild clean -project YouHQ.xcodeproj -scheme YouHQ
```

### Testing
Use Swift Testing framework (not XCTest) for new tests:
```bash
# Run all tests
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:YouHQTests/TestName
```

## Architecture

### Database Layer
- **SQLiteData** (PointFreeCo) is the persistence layer, wrapping GRDB
- Database initialization happens in `Database/AppDatabase.swift` via `appDatabase()` function
- All models use the `@Table` macro from SQLiteData (see `Database/Schema.swift`)
- Database is bootstrapped at app launch in `YouHQApp.init()` using PointFreeCo's Dependencies library
- Foreign key relationships are enforced with CASCADE deletes
- Triggers automatically update profile `updatedAt` timestamps when related data changes

### Core Tables
- **Profile**: Root entity, contains user profile(s) with `createdAt` and `updatedAt` timestamps
- **Residence, Vehicle, BankAccount, InvestmentAccount, HealthSavingsAccount, Job, InsurancePolicy**: All reference `profileID`
- **Utility**: References `residenceID` (child of Residence)
- **Device, ServiceProvider, Subscription**: Reference `profileID`

### Feature Organization
Code is organized by feature area in folders:
- `Residence/` - Home and utility management
- `Vehicle/` - Vehicle tracking
- `Money/` - Financial accounts (banking, investments, HSA)
- `Media/` - Devices, service providers, subscriptions
- `Career/` - Job history

Each feature typically has:
- `*Screen.swift` - SwiftUI view
- `*ViewModel.swift` - `@Observable` class containing business logic

### View Model Pattern
View models follow the SQLiteData + Observation pattern:
- Use `@Observable` macro for the view model class
- Use `@FetchAll` property wrapper to automatically load and observe database queries
- Mark database dependencies as `@ObservationIgnored` to prevent unnecessary observation
- Use `@Dependency(\.defaultDatabase)` to inject the database
- Load data via `$fetchAllProperty.load(query, animation: .default)` for animated updates
- Wrap database writes with `withErrorReporting { }` for error handling

See `Residence/ResidenceViewModel.swift` for reference implementation.

### Dependencies
- **swift-dependencies** (PointFreeCo): Dependency injection via `@Dependency` property wrapper
- **SQLiteData**: Type-safe SQLite queries with observable collections
- Database is prepared with `prepareDependencies { try! $0.bootstrapDatabase() }` in app initialization
- Foreign key relationships and indexes are created in migrations

### App Entry
- `YouHQApp.swift`: Main `@main` entry point, bootstraps database
- `AppEntryPoint.swift`: Root `TabView` with 5 tabs (Homes, Vehicles, Money, Media, Career)
- Each tab wraps its screen in a `NavigationStack`

## Code Conventions

### Modern Swift/SwiftUI (iOS 26+)
Target **iOS 26.0 or later** with **Swift 6.2+**. Follow all conventions from AGENTS.md, including:
- Swift concurrency (no GCD)
- `@Observable` classes (never `ObservableObject`)
- Modern SwiftUI APIs (`foregroundStyle`, `clipShape(.rect)`, `Tab` API)
- Static member lookup (`.circle` not `Circle()`)
- No force unwraps unless unrecoverable

### Database Operations
- Use `#sql()` macro for raw SQL in migrations
- Use SQLiteData's query DSL for type-safe queries: `.where { }`, `.order { }`, `.select { }`
- Always use `.eq()` for equality comparisons in queries
- Wrap writes in `database.write { db in }` blocks
- Use `.insert { }`, `.update { }`, `.delete()` fluent API
- Execute queries with `.execute(db)`

### Enums
All database enum types:
- Conform to `String, Codable, CaseIterable, QueryBindable`
- Use descriptive raw values (e.g., `"Full-Time"` not `"fullTime"`)

### Migrations
- Add new migrations via `migrator.registerMigration("Description") { db in }`
- In DEBUG builds, `eraseDatabaseOnSchemaChange = true` automatically handles schema changes
- Create indexes for foreign keys and common query patterns
- Use partial indexes with `WHERE` clauses for boolean flags

## Important Notes

- There is a default "Default" profile created automatically if none exists
- Sample data can be seeded with `try database.seed()` (see previews)
- Database path is printed at launch for debugging with `sqlite3` CLI
- All monetary amounts stored as `Double?` (nullable)
- Date fields use `Date?` for optional timestamps
- Boolean flags use `INTEGER` in SQLite (1/0)
- The app uses strict mode for SQLite tables

## SwiftLint
No SwiftLint configuration is currently present. If adding linting, create `.swiftlint.yml` and add build phase in Xcode.
