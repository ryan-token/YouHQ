//
//  PaintColorTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Paint Colors")
	struct PaintColorTests {

		@Suite("View model")
		struct ViewModel {
			@Dependency(\.defaultDatabase) var database

			@Test("Load fetches paint colors for a residence")
			func loadForResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(
							id: UUID(-3), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "Sherwin-Williams", colorName: "Alabaster"
						)
						PaintColor.Draft(
							id: UUID(-4), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "Benjamin Moore", colorName: "Simply White"
						)
					}
				}

				let vm = PaintColorViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.paintColors.count == 2)
			}

			@Test("Load for vehicle fetches paint colors scoped to vehicle")
			func loadForVehicle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						PaintColor.Draft(
							id: UUID(-3), residenceID: nil, vehicleID: UUID(-2),
							manufacturer: "Toyota", colorName: "Super White"
						)
					}
				}

				let vm = PaintColorViewModel()
				await vm.loadVehicle(for: UUID(-2))

				#expect(vm.paintColors.count == 1)
				let color = try #require(vm.paintColors.first)
				#expect(color.colorName == "Super White")
			}

			@Test("Paint colors are scoped to their parent entity")
			func scopedToParent() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "Home 1")
						Residence.Draft(id: UUID(-3), profileID: UUID(-1), street: "Home 2")
						PaintColor.Draft(
							id: UUID(-4), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "SW", colorName: "White"
						)
						PaintColor.Draft(
							id: UUID(-5), residenceID: UUID(-3), vehicleID: nil,
							manufacturer: "BM", colorName: "Gray"
						)
					}
				}

				let vm = PaintColorViewModel()
				await vm.load(for: UUID(-2))

				#expect(vm.paintColors.count == 1)
				let color = try #require(vm.paintColors.first)
				#expect(color.colorName == "White")
			}

			@Test("Create draft for residence has correct defaults")
			func createDraftForResidence() {
				let vm = PaintColorViewModel()
				let draft = vm.createDraft(for: UUID(-1))

				#expect(draft.residenceID == UUID(-1))
				#expect(draft.vehicleID == nil)
				#expect(draft.manufacturer == "")
				#expect(draft.colorName == "")
				#expect(draft.finish == .eggshell)
				#expect(draft.backgroundColor == "purple")
			}

			@Test("Create draft for vehicle has correct defaults")
			func createDraftForVehicle() {
				let vm = PaintColorViewModel()
				let draft = vm.createVehicleDraft(for: UUID(-1))

				#expect(draft.residenceID == nil)
				#expect(draft.vehicleID == UUID(-1))
				#expect(draft.manufacturer == "")
				#expect(draft.colorName == "")
				#expect(draft.finish == .eggshell)
				#expect(draft.backgroundColor == "purple")
			}
		}

		// MARK: - PaintColorsScreen.ViewModel Tests

		@Suite("Screen view model")
		struct ScreenViewModel {
			@Dependency(\.defaultDatabase) var database

			@Test("showAddPaintColorSheet sets draft with correct residence ID")
			func showAddForResidence() throws {
				let vm = PaintColorsScreen.ViewModel(residenceID: UUID(-1), vehicleID: nil)
				vm.showAddPaintColorSheet()

				let draft = try #require(vm.draftPaintColor)
				#expect(draft.residenceID == UUID(-1))
				#expect(draft.vehicleID == nil)
				#expect(vm.isNewItem == true)
				#expect(vm.isShowingEditSheet == true)
			}

			@Test("showAddPaintColorSheet sets draft with correct vehicle ID")
			func showAddForVehicle() throws {
				let vm = PaintColorsScreen.ViewModel(residenceID: nil, vehicleID: UUID(-2))
				vm.showAddPaintColorSheet()

				let draft = try #require(vm.draftPaintColor)
				#expect(draft.residenceID == nil)
				#expect(draft.vehicleID == UUID(-2))
				#expect(vm.isNewItem == true)
				#expect(vm.isShowingEditSheet == true)
			}

			@Test("editPaintColor sets draft from existing item")
			func editExisting() throws {
				let existing = PaintColor(
					id: UUID(-1), residenceID: UUID(-2), vehicleID: nil,
					manufacturer: "SW", colorName: "Alabaster", colorCode: "SW 7008",
					room: "Living Room", finish: .satin, purchaseDate: nil,
					surfaceType: "Drywall", storePurchasedFrom: "Home Depot",
					applicationDate: nil, backgroundColor: "blue", url: "", notes: ""
				)

				let vm = PaintColorsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				vm.editPaintColor(existing)

				let draft = try #require(vm.draftPaintColor)
				#expect(draft.id == UUID(-1))
				#expect(draft.colorName == "Alabaster")
				#expect(vm.isNewItem == false)
				#expect(vm.isShowingEditSheet == true)
				#expect(vm.sheetTransitionSourceID == UUID(-1).uuidString)
			}

			@Test("deletePaintColor removes from database")
			func deleteRemovesFromDB() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(
							id: UUID(-3), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "SW", colorName: "Alabaster"
						)
					}
				}

				let existing = try await database.read { db in
					try PaintColor.find(UUID(-3)).fetchOne(db)
				}
				let color = try #require(existing)

				let vm = PaintColorsScreen.ViewModel(residenceID: UUID(-2), vehicleID: nil)
				vm.deletePaintColor(color)

				let count = try await database.read { db in try PaintColor.fetchCount(db) }
				#expect(count == 0)
			}
		}

		// MARK: - Cascade Deletion

		@Suite("Cascade deletion")
		struct CascadeDeletion {
			@Dependency(\.defaultDatabase) var database

			@Test("Deleting a residence cascades to its paint colors")
			func cascadeFromResidence() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(
							id: UUID(-3), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "SW", colorName: "White"
						)
						PaintColor.Draft(
							id: UUID(-4), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "BM", colorName: "Gray"
						)
					}
				}

				try await database.write { db in
					try Residence.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in try PaintColor.fetchCount(db) }
				#expect(count == 0)
			}

			@Test("Deleting a vehicle cascades to its paint colors")
			func cascadeFromVehicle() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Vehicle.Draft(id: UUID(-2), profileID: UUID(-1), make: "Toyota")
						PaintColor.Draft(
							id: UUID(-3), residenceID: nil, vehicleID: UUID(-2),
							manufacturer: "Toyota", colorName: "Super White"
						)
					}
				}

				try await database.write { db in
					try Vehicle.find(UUID(-2)).delete().execute(db)
				}

				let count = try await database.read { db in try PaintColor.fetchCount(db) }
				#expect(count == 0)
			}

			@Test("Deleting a profile cascades through residence to paint colors")
			func cascadeFromProfile() async throws {
				try await database.write { db in
					try db.seed {
						Profile.Draft(id: UUID(-1), name: "Test", createdAt: Date(), updatedAt: Date())
						Residence.Draft(id: UUID(-2), profileID: UUID(-1), street: "123 Main")
						PaintColor.Draft(
							id: UUID(-3), residenceID: UUID(-2), vehicleID: nil,
							manufacturer: "SW", colorName: "White"
						)
					}
				}

				try await database.write { db in
					try Profile.find(UUID(-1)).delete().execute(db)
				}

				let paintCount = try await database.read { db in try PaintColor.fetchCount(db) }
				let residenceCount = try await database.read { db in try Residence.fetchCount(db) }
				#expect(paintCount == 0)
				#expect(residenceCount == 0)
			}
		}
	}
}
