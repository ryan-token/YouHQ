//
//  ResidenceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

struct ResidenceEdit: View {
	@State private var vm: ViewModel
	@Binding var selectedResidence: Residence?

	init(
		residence: Residence?,
		profileID: UUID,
		selectedResidence: Binding<Residence?>
	) {
		_selectedResidence = selectedResidence
		_vm = State(
			wrappedValue: ViewModel(residence: residence, profileID: profileID)
		)
	}

	var body: some View {
		NavigationStack {
			Form {
				BasicInfoSection(vm: vm)
				AddressSection(vm: vm)
				DatesSection(vm: vm)
				CostSection(vm: vm)
				UtilitiesSection(vm: vm)
				URLSection(vm: vm)
				NotesSection(vm: vm)
			}
			.navigationTitle(vm.isEditing ? "Edit Residence" : "New Residence")
			.apply {
				#if !os(macOS)
					$0.navigationBarTitleDisplayMode(.inline)
				#endif
			}
			.apply {
				#if !os(visionOS)
					$0.scrollDismissesKeyboard(.immediately)
				#endif
			}
			.toolbar { Toolbar(vm: vm, selectedResidence: $selectedResidence) }
		}
		.interactiveDismissDisabled()
	}
}

#Preview("New Residence") {
	@Previewable @State var selected: Residence?
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}
	ResidenceEdit(
		residence: nil,
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}

#Preview("Edit Residence") {
	@Previewable @State var selected: Residence? = Residence.sampleData
	let _ = prepareDependencies {
		try! $0.bootstrapDatabase()
		try! $0.defaultDatabase.seed()
	}
	ResidenceEdit(
		residence: Residence.sampleData,
		profileID: Profile.sampleData.id,
		selectedResidence: $selected
	)
}
