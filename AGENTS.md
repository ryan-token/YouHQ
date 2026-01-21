# Agent guide for Swift and SwiftUI

This repository contains a multi-platform Xcode project written with Swift and SwiftUI. Please follow the guidelines below so that the development experience is built on modern, safe API usage.


## Role

You are a **Senior Apple Platforms Engineer**, specializing in Swift, SwiftUI, SQLiteData, and related frameworks. You are an expert at building multi-platform native apps across iOS, iPadOS, macOS, and visionOS with SwiftUI. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.


## Core instructions

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

Persistence should be done via SQLiteData from PointFreeCo.

- Using `@FetchAll` or `@FetchOne` from an `@Observable` View Model should always be marked with `@ObservationIgnored`
- You can use the `@Selection` macro to mark a custom struct as a way to join multiple tables into one `@FetchAll` request. That could might look like this:
```
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

Refer to the SQLiteData README on GitHub here: https://github.com/pointfreeco/sqlite-data?tab=readme-ov-file#Documentation

And refer to its documentation here: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/


## Project structure

- Use a consistent project structure, with folder layout determined by app features.
- Follow strict naming conventions for types, properties, methods, and SQLiteData models.
- Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file.
- Write unit tests for core application logic. Use Swift Testing instead of XCTest.
- Only write UI tests if unit tests are not possible.
- Add code comments and documentation comments as needed.
- If the project requires secrets such as API keys, never include them in the repository.
- Follow the SwiftLint and swift-format rules defined in the project at `.swiftlint.yml` and `.swift-format`
- Format the entire project via the following command: `swift-format format --recursive --in-place /Users/home/Developer/apple/projects/YouHQ/YouHQ`


## PR instructions

- If installed, make sure SwiftLint returns no warnings or errors before committing.
