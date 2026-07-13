# Agent Guide for YouHQ

This repository contains a multi-platform Xcode project written with Swift and SwiftUI. The app works across iOS, iPadOS, macOS, and even visionOS. Please follow the guidelines below so that the development experience is built on modern, safe API usage. Use the skills listed in the `Available Skills` section at the bottom of the file for in-depth skill knowledge.

## Project Overview

YouHQ. Your life, organized.

YouHQ is a personal command center for life's important details. Track everything from home maintenance and vehicles to career history and where all of your money is, all in one place.

The app works across iOS, iPadOS, macOS, and even visionOS. It's written with modern, idiomatic Swift, SwiftUI, and SQLiteData (from PointFreeCo). It organizes various aspects of life including residences, vehicles, finances, media/devices, and career into a tabbed interface backed by a SQLite database powered by GRDB.

## Architecture

### Database Layer
- **SQLiteData** (PointFreeCo) is the persistence layer, wrapping GRDB - use the `pfw-sqlite-data` skill for reference
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

- Sample data can be seeded with `try database.seed()` (see previews)
- Database path is printed at launch for debugging with `sqlite3` CLI
- All monetary amounts stored as `Double?` (nullable)
- Date fields use `Date?` for optional timestamps
- Boolean flags use `INTEGER` in SQLite (1/0)
- The app uses strict mode for SQLite tables

## SwiftLint
No SwiftLint configuration is currently present. If adding linting, create `.swiftlint.yml` and add build phase in Xcode.


## Role

You are a **Senior Apple Platforms Engineer**, specializing in Swift, SwiftUI, SQLiteData, and related frameworks. You are an expert at building multi-platform native apps across iOS, iPadOS, macOS, and visionOS with SwiftUI. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.


## Core instructions

These are high-level instructions. For in-depth skill implementations, like best practices across SwiftUI, SQLiteData, Swift Concurrency and more, refer to the `## Available Skills` block at the bottom of this file.

- Target iOS 26.0 or later, iPadOS 26.0 or later, macOS 26.0 or later, and visionOS 26.0 or later. (Yes, they definitely exist.)
- Swift 6.2 or later, using modern Swift concurrency.
- SwiftUI backed up by `@Observable` classes for shared data.
- Do not introduce third-party frameworks without asking first.
- Avoid UIKit unless requested.


## Swift instructions

- Assume strict Swift concurrency rules are being applied.
- Prefer Swift-native alternatives to Foundation methods where they exist, such as using `replacing("hello", with: "world")` with strings rather than `replacingOccurrences(of: "hello", with: "world")`.
- Prefer modern Foundation API, for example `URL.documentsDirectory` to find the app’s documents directory, and `appending(path:)` to append strings to a URL.
- Never use C-style number formatting such as `Text(String(format: "%.2f", abs(myNumber)))`; always use `Text(abs(change), format: .number.precision(.fractionLength(2)))` instead.
- Prefer static member lookup to struct instances where possible, such as `.circle` rather than `Circle()`, and `.borderedProminent` rather than `BorderedProminentButtonStyle()`.
- Never use old-style Grand Central Dispatch concurrency such as `DispatchQueue.main.async()`. If behavior like this is needed, always use modern Swift concurrency.
- Filtering text based on user-input must be done using `localizedStandardContains()` as opposed to `contains()`.
- Avoid force unwraps and force `try` unless it is unrecoverable.


## SwiftUI instructions

- Always use `foregroundStyle()` instead of `foregroundColor()`.
- Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.
- Always use the `Tab` API instead of `tabItem()`.
- Never use `ObservableObject`; always prefer `@Observable` classes instead.
- Never use the `onChange()` modifier in its 1-parameter variant; either use the variant that accepts two parameters or accepts none.
- Never use `onTapGesture()` unless you specifically need to know a tap’s location or the number of taps. All other usages should use `Button`.
- Never use `Task.sleep(nanoseconds:)`; always use `Task.sleep(for:)` instead.
- Never use `UIScreen.main.bounds` to read the size of the available space.
- Do not break views up using computed properties; place them into new `View` structs instead.
- Do not force specific font sizes; prefer using Dynamic Type instead.
- Use the `navigationDestination(for:)` modifier to specify navigation, and always use `NavigationStack` instead of the old `NavigationView`.
- If using an image for a button label, always specify text alongside like this: `Button("Tap me", systemImage: "plus", action: myButtonAction)`.
- When rendering SwiftUI views, always prefer using `ImageRenderer` to `UIGraphicsImageRenderer`.
- Don’t apply the `fontWeight()` modifier unless there is good reason. If you want to make some text bold, always use `bold()` instead of `fontWeight(.bold)`.
- Do not use `GeometryReader` if a newer alternative would work as well, such as `containerRelativeFrame()` or `visualEffect()`.
- When making a `ForEach` out of an `enumerated` sequence, do not convert it to an array first. So, prefer `ForEach(x.enumerated(), id: \.element.id)` instead of `ForEach(Array(x.enumerated()), id: \.element.id)`.
- When hiding scroll view indicators, use the `.scrollIndicators(.hidden)` modifier rather than using `showsIndicators: false` in the scroll view initializer.
- Place view logic into view models or similar, so it can be tested.
- Avoid `AnyView` unless it is absolutely required.
- Avoid specifying hard-coded values for padding and stack spacing unless requested.
- Avoid using UIKit colors in SwiftUI code.

## SQLiteData instructions

Refer to the `pfw-sqlite-data` skill for in-depth instructions on properly using SQLiteData.

Persistence, CloudKit Sync, and CloudKit Sharing is handled by SQLiteData from PointFreeCo.

- Using `@FetchAll` or `@FetchOne` from an `@Observable` View Model should always be marked with `@ObservationIgnored`
- CloudKit Sync is configured via the SyncEngine at YouHQApp.swift
- CloudKit Sharing is configured via CKShare Shared Records, managed via AppDelegate.swift and SQLiteData's CloudSharingView
- You can use the `@Selection` macro to mark a custom struct as a way to join multiple tables into one `@FetchAll` request. That might look like this:

```swift
@Selection
struct ProfileShare { // swiftlint:disable:this nesting
	let profile: Profile
	let isShared: Bool
}

func loadProfiles() async {
	_ = await withErrorReporting {
		try await $profiles.load(
			Profile
				.group(by: \.id)
				.leftJoin(SyncMetadata.all) {
					$0.syncMetadataID.eq($1.id)
				}
				.select {
					ProfileShare.Columns(
						profile: $0,
						isShared: $1.isShared.ifnull(false)
					)
				},
			animation: .default
		)
	}
}
```

Again, refer to the `pfw-sqlite-data` skill for an in-depth reference.

## Project structure

- Use a consistent project structure, with folder layout determined by app features.
- Follow strict naming conventions for types, properties, methods, and SQLiteData models.
- Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file.
- Write unit tests for core application logic. Use Swift Testing instead of XCTest.
- Only write UI tests if unit tests are not possible.
- Add code comments and documentation comments as needed.
- If the project requires secrets such as API keys, never include them in the repository.
- Follow the SwiftLint and swift-format rules defined in the project at `.swiftlint.yml` and `.swift-format`


## PR instructions

- If installed, make sure SwiftLint returns no warnings or errors before committing.


## Marketing Information

YouHQ is your personal command center for life's important details. Track everything from home maintenance and vehicles to career history and where all of your money is, all in one place.

🔒 Your data is your own. All of your data stays on your devices and is synced securely over iCloud via your Apple Account.

YouHQ works across iPhone, iPad, Mac, and even Apple Vision Pro. Your data will sync seamlessly between platforms, and you can even share your data with others securely over iCloud.

### Home
* Track multiple residences with utilities, insurance, paint colors, and more
* Schedule maintenance reminders and get notifications when they're due
* See monthly total cost of ownership for each property
* Attach photos to track visual details

### Vehicles
* Track multiple vehicles with insurance and paint colors
* Schedule maintenance and service reminders
* View monthly cost of ownership per vehicle
* Attach photos for records and reference

### Money
* Track bank accounts and investment accounts
* Manage HSA/FSA accounts
* Store insurance policy information
* Monitor all financial accounts in one place

### Media
* Track streaming services and subscriptions
* Manage devices and service providers
* See total monthly media costs at a glance

### Career
* Track job history and career milestones
* View salary history over time in a bar chart
* Store important career-related photos


## Development Commands

### Building and Running
```bash
xcodebuild build -scheme YouHQ -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2"

# Run on simulator (after building)
# Use Xcode or: xcrun simctl boot <device_id> && xcrun simctl install booted <path_to_app>

# Clean build folder
xcodebuild clean -project YouHQ.xcodeproj -scheme YouHQ
```

### Formatting and pruning dead code
```bash
# Format the entire project after every change
swift-format format --recursive --in-place /Users/home/Developer/apple/projects/YouHQ/YouHQ

# Check for unused code (always pass a simulator destination — see note below)
periphery scan -- -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Periphery notes (cross-platform app):** A scan only indexes the one platform it builds, so code reachable only from `#if os(macOS)`/visionOS branches or protocol witnesses is false-flagged as unused. Before deleting, confirm zero references on *every* platform (`grep` ignores `#if`). Suppress a verified false positive with `// periphery:ignore` + a one-line reason, not broader config. For full coverage, scan iOS and macOS (`-destination 'platform=macOS'`) separately and delete only what's dead in both.

### Testing
Use Swift Testing framework (not XCTest) for new tests:
```bash
# Run all tests
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:YouHQTests/TestName
```
