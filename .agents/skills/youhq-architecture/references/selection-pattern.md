# The `@Selection` pattern

Use the `@Selection` macro when one `@FetchAll` needs columns from more than one
table. It marks a plain struct as a selectable row shape, so the join result stays
type-safe instead of collapsing into a tuple.

Declare the struct alongside the view model that fetches it, then build the query
with the generated `.Columns` initializer.

```swift
@Selection
struct ProfileShare {  // swiftlint:disable:this nesting
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

Notes on this example:

- `leftJoin` against `SyncMetadata` is how a row learns whether it is shared over
  iCloud. An inner join would drop every unshared profile.
- `.ifnull(false)` is required on the joined side — a left join yields `NULL` for
  rows with no match, and `isShared` is non-optional.
- Nesting the struct inside a view model trips SwiftLint's `nesting` rule; the
  inline disable comment above is the project's convention for that.
