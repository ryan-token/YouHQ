# Agent Guide for YouHQ

This repository contains a multi-platform Xcode project written with Swift and SwiftUI. The app works across iOS, iPadOS, macOS, and even visionOS. Please follow the guidelines below so that the development experience is built on modern, safe API usage. Reach for skills for depth: this repo ships `youhq-architecture` (layout, schema, sync wiring) and `youhq-app-store-copy`. Library and language practice comes from `pfw-sqlite-data`, `swiftui-pro`, `swift-concurrency-pro`, and `swift-testing-pro`, which are installed per-developer rather than vendored here.

## Project Overview

YouHQ. Your life, organized.

YouHQ is a personal command center for life's important details. Track everything from home maintenance and vehicles to career history and where all of your money is, all in one place.

The app works across iOS, iPadOS, macOS, and even visionOS. It's written with modern, idiomatic Swift, SwiftUI, and SQLiteData (from PointFreeCo). It organizes various aspects of life including residences, vehicles, finances, media/devices, and career into a tabbed interface backed by a SQLite database powered by GRDB.

## Architecture

Use the **`youhq-architecture` skill** for the feature-folder layout, the schema's
ownership graph, migration and trigger rules, and the CloudKit sync/sharing wiring.

Persistence is **SQLiteData** (PointFreeCo) wrapping GRDB — use the `pfw-sqlite-data`
skill for library reference. Two things bite often enough to keep here:

- Foreign keys cascade on delete, so removing a `Profile` removes everything under it.
- Triggers keep `Profile.updatedAt` fresh when related rows change, and every one of
  them must be sync-guarded or it churns CloudKit. See the skill before writing one.

### View Model Pattern
View models follow the SQLiteData + Observation pattern:
- Use `@Observable` macro for the view model class
- Use `@FetchAll` property wrapper to automatically load and observe database queries
- Mark database dependencies as `@ObservationIgnored` to prevent unnecessary observation
- Use `@Dependency(\.defaultDatabase)` to inject the database
- Load data via `$fetchAllProperty.load(query, animation: .default)` for animated updates
- Wrap database writes with `withErrorReporting { }` for error handling

See `Residence/ResidenceViewModel.swift` for reference implementation.

## Code Conventions

### Enums
All database enum types:
- Conform to `String, Codable, CaseIterable, QueryBindable`
- Use descriptive raw values (e.g., `"Full-Time"` not `"fullTime"`)

### Migrations
- Add new migrations via `migrator.registerMigration("Description") { db in }`
- Migrations are additive and never edited after shipping — there is no
  erase-on-schema-change escape hatch, in DEBUG or anywhere else
- Create indexes for foreign keys and common query patterns
- Use partial indexes with `WHERE` clauses for boolean flags

## Important Notes

- Sample data can be seeded with `try database.seed()` (see previews)
- Database path is printed at launch for debugging with `sqlite3` CLI
- All monetary amounts stored as `Double?` (nullable)
- Date fields use `Date?` for optional timestamps
- Boolean flags use `INTEGER` in SQLite (1/0)
- The app uses strict mode for SQLite tables

## Role

You are a **Senior Apple Platforms Engineer**, specializing in Swift, SwiftUI, SQLiteData, and related frameworks. You are an expert at building multi-platform native apps across iOS, iPadOS, macOS, and visionOS with SwiftUI. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.


## Core instructions

These are high-level instructions. For in-depth practice across SwiftUI, SQLiteData, and Swift concurrency, use the skills named in the intro above.

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
- Join multiple tables into one `@FetchAll` with the `@Selection` macro — see the
  `youhq-architecture` skill for the pattern and a worked example

Again, refer to the `pfw-sqlite-data` skill for an in-depth reference.

## Project structure

- Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file.
- Write unit tests for core application logic. Use Swift Testing instead of XCTest.
- Only write UI tests if unit tests are not possible.
- Never commit secrets. `Secrets.xcconfig` is local-only; `Secrets.xcconfig.example` is the tracked template.


## PR instructions

- SwiftLint is configured at `.swiftlint.yml`. Make sure it returns no warnings or errors before committing.


## Marketing Information

App Store copy, the privacy promise, and the per-category feature bullets live in the
**`youhq-app-store-copy` skill**. Use it for any user-facing description of the app.


## Development Commands

### Building and Running

Pipe every `xcodebuild`/`swift build` invocation through `xcsift` for structured output.

```bash
xcodebuild build -scheme YouHQ -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.5" | xcsift

# Run on simulator (after building)
# Use Xcode or: xcrun simctl boot <device_id> && xcrun simctl install booted <path_to_app>

# Clean build folder
xcodebuild clean -project YouHQ.xcodeproj -scheme YouHQ
```

Installed simulator runtimes are iOS 26.5 and 27.0 — confirm with
`xcrun simctl list runtimes` rather than assuming a version.

### Formatting and pruning dead code
```bash
# Format the entire project after every change (run from the repo root)
swift-format format --recursive --in-place YouHQ

# Check for unused code (always pass a simulator destination — see note below)
periphery scan -- -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Periphery notes (cross-platform app):** A scan only indexes the one platform it builds, so code reachable only from `#if os(macOS)`/visionOS branches or protocol witnesses is false-flagged as unused. Before deleting, confirm zero references on *every* platform (`grep` ignores `#if`). Suppress a verified false positive with `// periphery:ignore` + a one-line reason, not broader config. For full coverage, scan iOS and macOS (`-destination 'platform=macOS'`) separately and delete only what's dead in both.

### Testing
Use Swift Testing framework (not XCTest) for new tests:
```bash
# Run all tests
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcsift

# Run specific test
xcodebuild test -project YouHQ.xcodeproj -scheme YouHQ -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:YouHQTests/TestName | xcsift
```

## Xcode MCP

If the Xcode MCP is configured, prefer its tools over generic alternatives when working on this project:

- `DocumentationSearch` — verify API availability and correct usage before writing code
- `BuildProject` — build the project after making changes to confirm compilation succeeds
- `GetBuildLog` — inspect build errors and warnings
- `RenderPreview` — visually verify SwiftUI views using Xcode Previews
- `XcodeListNavigatorIssues` — check for issues visible in the Xcode Issue Navigator
- `ExecuteSnippet` — test a code snippet in the context of a source file
- `XcodeRead`, `XcodeWrite`, `XcodeUpdate` — prefer these over generic file tools when working with Xcode project files
