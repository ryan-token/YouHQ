//
//  ProfileManagerTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("ProfileManager")
	struct ProfileManagerTests {

		/// A concrete test double for `ProfileSelection` protocol.
		final class MockProfileSelection: ProfileSelection {
			var profiles: [ProfileShare]
			var selectedProfileIDString: String

			init(profiles: [ProfileShare] = [], selectedProfileIDString: String = "") {
				self.profiles = profiles
				self.selectedProfileIDString = selectedProfileIDString
			}
		}

		// MARK: - currentProfileID

		@Suite("currentProfileID")
		struct CurrentProfileID {
			@Test("Getter returns nil when string is empty")
			func emptyStringReturnsNil() {
				let selection = MockProfileSelection()
				selection.selectedProfileIDString = ""
				#expect(selection.currentProfileID == nil)
			}

			@Test("Getter returns nil for invalid UUID string")
			func invalidUUIDReturnsNil() {
				let selection = MockProfileSelection()
				selection.selectedProfileIDString = "not-a-uuid"
				#expect(selection.currentProfileID == nil)
			}

			@Test("Getter returns UUID for valid UUID string")
			func validUUIDStringReturnsUUID() {
				let id = UUID(-1)
				let selection = MockProfileSelection()
				selection.selectedProfileIDString = id.uuidString
				#expect(selection.currentProfileID == id)
			}

			@Test("Setter stores UUID string")
			func setterStoresUUID() {
				let id = UUID(-1)
				let selection = MockProfileSelection()
				selection.currentProfileID = id
				#expect(selection.selectedProfileIDString == id.uuidString)
			}

			@Test("Setter clears to empty string when set to nil")
			func setterClearsOnNil() {
				let selection = MockProfileSelection()
				selection.selectedProfileIDString = UUID(-1).uuidString
				selection.currentProfileID = nil
				#expect(selection.selectedProfileIDString == "")
			}
		}

		// MARK: - getSelectedProfileID

		@Suite("getSelectedProfileID")
		struct GetSelectedProfileID {
			@Test("Returns stored ID when it exists in profiles")
			func returnsStoredID() {
				let profile = Profile(id: UUID(-1), name: "Alice")
				let share = ProfileShare(profile: profile, isShared: false, metadata: nil)
				let selection = MockProfileSelection(
					profiles: [share],
					selectedProfileIDString: UUID(-1).uuidString
				)

				let result = selection.getSelectedProfileID()
				#expect(result == UUID(-1))
			}

			@Test("Falls back to first profile when stored ID is missing from profiles")
			func fallsBackToFirst() {
				let profile = Profile(id: UUID(-2), name: "Bob")
				let share = ProfileShare(profile: profile, isShared: false, metadata: nil)
				let selection = MockProfileSelection(
					profiles: [share],
					selectedProfileIDString: UUID(-999).uuidString
				)

				let result = selection.getSelectedProfileID()
				#expect(result == UUID(-2))
				// Also verifies it updated the stored ID
				#expect(selection.selectedProfileIDString == UUID(-2).uuidString)
			}

			@Test("Falls back to first profile when stored ID string is empty")
			func fallsBackWhenEmpty() {
				let profile = Profile(id: UUID(-1), name: "Charlie")
				let share = ProfileShare(profile: profile, isShared: false, metadata: nil)
				let selection = MockProfileSelection(
					profiles: [share],
					selectedProfileIDString: ""
				)

				let result = selection.getSelectedProfileID()
				#expect(result == UUID(-1))
			}

			@Test("Returns nil when no profiles exist")
			func returnsNilWhenNoProfiles() {
				let selection = MockProfileSelection(profiles: [])

				let result = selection.getSelectedProfileID()
				#expect(result == nil)
			}
		}

		// MARK: - getSelectedProfile

		@Suite("getSelectedProfile")
		struct GetSelectedProfile {
			@Test("Returns matching profile share when stored ID exists")
			func returnsMatchingProfile() {
				let profile = Profile(id: UUID(-1), name: "Alice")
				let share = ProfileShare(profile: profile, isShared: false, metadata: nil)
				let selection = MockProfileSelection(
					profiles: [share],
					selectedProfileIDString: UUID(-1).uuidString
				)

				let result = selection.getSelectedProfile()
				#expect(result?.profile.name == "Alice")
			}

			@Test("Returns first profile when stored ID not found")
			func returnsFirstProfileOnMismatch() {
				let alice = Profile(id: UUID(-1), name: "Alice")
				let bob = Profile(id: UUID(-2), name: "Bob")
				let shares = [
					ProfileShare(profile: alice, isShared: false, metadata: nil),
					ProfileShare(profile: bob, isShared: false, metadata: nil),
				]
				let selection = MockProfileSelection(
					profiles: shares,
					selectedProfileIDString: UUID(-999).uuidString
				)

				let result = selection.getSelectedProfile()
				#expect(result?.profile.name == "Alice")
			}

			@Test("Returns nil when no profiles exist")
			func returnsNilWhenEmpty() {
				let selection = MockProfileSelection(profiles: [])
				let result = selection.getSelectedProfile()
				#expect(result == nil)
			}
		}
	}
}
