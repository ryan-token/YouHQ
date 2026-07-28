---
name: youhq-architecture
description: Architecture and data-model reference for the YouHQ multi-platform SwiftUI app — feature-folder layout, the SQLiteData/GRDB schema and its ownership rules, migrations and triggers, CloudKit sync and sharing wiring, and the view-model pattern. Use when orienting in an unfamiliar area of the codebase, adding a table, column, or migration, writing a trigger, tracing how a record reaches iCloud, or deciding where new feature code belongs.
---

# YouHQ Architecture

YouHQ is a personal life-organizer for iOS, iPadOS, macOS, and visionOS: residences,
vehicles, finances, media/devices, and career history in a tabbed interface over a
local SQLite database that syncs through iCloud.

This file describes shape and rules. For anything countable — fields, migrations,
triggers, file lists — read the source; it is the only accurate answer.

## Orientation

All app code lives under `YouHQ/`.

**Feature folders** own one domain each and typically pair a `*Screen.swift` SwiftUI
view with an `@Observable` `*ViewModel.swift`: `Career`, `Insurance`, `Maintenance`,
`Media`, `Money`, `Other`, `PaintColor`, `Residence`, `Vehicle`.

**Cross-cutting folders**: `Database`, `Extensions`, `Helpers`, `Notifications`,
`Onboarding`, `Paywall`, `PhotoPicker`, `SectionEdit`, `Settings`, `Shared Views`,
`View Modifiers`.

**Entry points**: `YouHQApp.swift` (`@main`; bootstraps the database and sync engine)
→ `AppEntryPoint.swift` → `AppTabView.swift`, which declares five tabs — Home,
Vehicles, Money, Media, Career — each wrapped in its own `NavigationStack`.

**Database layer** lives in `YouHQ/Database/`: `Schema.swift` (table types),
`AppDatabase.swift` (migrations, triggers, connection setup), plus seeding helpers.

## Data model

`Schema.swift` declares every table as a `nonisolated` `@Table` struct. Read it for
fields. What follows is the ownership graph, which the declarations alone don't show.

`Profile` is the root entity. Three ownership shapes hang off it:

1. **Profile-owned** — a non-optional `let profileID: Profile.ID`. Most tables:
   `Residence`, `Vehicle`, `BankAccount`, `InvestmentAccount`,
   `HealthSavingsAccount`, `ServiceProvider`, `Device`, `Subscription`, `Job`,
   `InsurancePolicy`, `Other`, `Asset`.

2. **Single-parent child** — `Utility` (`residenceID`), `MaintenanceCompletion`
   (`maintenanceItemID`).

3. **Polymorphic either-or** — `MaintenanceItem`, `PaintColor`, `InsurancePolicy`,
   `Other`, and `Asset` each carry *both* `residenceID: Residence.ID?` and
   `vehicleID: Vehicle.ID?`, and belong to exactly one. `Asset` additionally takes
   `maintenanceItemID: MaintenanceItem.ID?`.

`AppSettings` stands alone and maps to a custom table name via `@Table("appSettings")`.

Every foreign key cascades on delete.

## Core rules

1. **Filter polymorphic tables on the parent you mean, and set the other parent to
   `nil` on insert.** Nothing in the type system enforces the either-or in shape 3
   above. A query that omits the filter silently returns another parent's rows —
   a vehicle's paint colors showing up under a residence, with no error.

2. **Never write `= nil` as a default on a `@Table` optional.** It breaks the macro's
   column synthesis. Declare `var x: T?` and stop there.

3. **Schema changes are additive migrations** registered in order in
   `AppDatabase.swift`. Reusing a CloudKit field name that was previously deployed
   resurrects its stale server values over freshly migrated ones, because
   `updateLocalFromSchemaChange` replays `lastKnownServerRecord` into any column new
   to `tableInfo`. Give a repurposed column a genuinely new name.

4. **Every trigger that writes MUST be sync-guarded.** Unguarded, a trigger fires on
   sync-applied writes too, so one remote change bumps `profiles.updatedAt`, which
   re-uploads, which fires again — an endless churn loop. Guard with
   `WHEN NOT \(SyncEngine.$isSynchronizing)` and register the function per connection
   with `db.add(function: SyncEngine.$isSynchronizing)` in `prepareDatabase`, so it
   also resolves in tests and previews.

5. **Migrations cannot reach other devices.** Sync triggers are temporary and install
   at `SyncEngine.init`, so anything a migration writes is invisible to CloudKit and
   never uploads. Run data backfills that must propagate as ordinary app writes after
   `initializeSQLiteData()`.

6. **CloudKit is wired in two places.** Sync: `SyncEngine`, configured in
   `YouHQApp.swift`. Sharing: `CKShare` records via `AppDelegate.swift` plus
   SQLiteData's `CloudSharingView`. A record that syncs but won't share — or the
   reverse — is nearly always a gap in one of those two, not in the schema.

## View models

Feature view models follow one shape:

- `@Observable` class, never `ObservableObject`
- `@FetchAll` / `@FetchOne` properties marked `@ObservationIgnored`; without it the
  fetch's own writes retrigger observation
- `@Dependency(\.defaultDatabase)` for the database handle
- Load with `$property.load(query, animation: .default)`
- Wrap writes in `withErrorReporting { }`

`Residence/ResidenceViewModel.swift` is the reference implementation.

## References

- [selection-pattern.md](references/selection-pattern.md) — joining multiple tables
  into one `@FetchAll` with the `@Selection` macro, including the profile-sharing
  example

For SQLiteData API usage beyond these project conventions, use the `pfw-sqlite-data`
skill rather than duplicating its guidance here.
