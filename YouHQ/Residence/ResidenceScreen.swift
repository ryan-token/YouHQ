//
//  ResidenceScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct ResidenceScreen: View {
	@Dependency(\.defaultDatabase) var database
	@FetchAll var profiles: [Profile]
	@FetchAll(animation: .default) var residences: [Residence]
	@State private var isNewResidenceAlertPresented = false
	@State private var newResidenceAddress = ""

    var body: some View {
		List {
			ForEach(residences) { residence in
				Text(residence.street)
			}
			.onDelete { offsets in
				withErrorReporting {
					try database.write { db in
						try Residence.find(offsets.map { residences[$0].id })
							.delete()
							.execute(db)
					}
				}
			}
		}
		.navigationTitle("Home")
		.alert("Create new residence", isPresented: $isNewResidenceAlertPresented) {
			TextField("Address", text: $newResidenceAddress)
			Button("Save") {
				guard let profileID = profiles.first?.id else { return }
				withErrorReporting {
					try database.write { db in
						try Residence.insert {
							Residence.Draft(
								profileID: profileID,
								street: newResidenceAddress
							)
						}
						.execute(db)
					}
				}
			}
			Button(role: .cancel) {}
		}

		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isNewResidenceAlertPresented = true
				} label: {
					Label("Add Residence", systemImage: "plus")
				}
			}
		}
    }
}

#Preview {
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}

    NavigationStack {
    	ResidenceScreen()
    }
}
