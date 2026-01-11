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
	@Binding var isShowingEditSheet: Bool

	init(
		residence: Residence?,
		profileID: UUID,
		selectedResidence: Binding<Residence?>,
		isShowingEditSheet: Binding<Bool>
	) {
		_selectedResidence = selectedResidence
		_isShowingEditSheet = isShowingEditSheet
		_vm = State(
			wrappedValue: ViewModel(residence: residence, profileID: profileID)
		)
	}

	var body: some View {
		NavigationStack {
			List {
				BasicInfoSection(vm: vm)
				AddressSection(vm: vm)
				DatesSection(vm: vm)
				CostSection(vm: vm)
				UtilitiesSection(vm: vm)
				InsuranceSection(vm: vm)
				URLSection(vm: vm)
				NotesSection(vm: vm)
			}
			.frame(minHeight: 400)
			.navigationTitle(vm.isEditing ? "Edit Residence" : "New Residence")
			#if !os(macOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
			#if !os(visionOS)
				.scrollDismissesKeyboard(.immediately)
			#endif
			.toolbar {
				Toolbar(
					vm: vm,
					selectedResidence: $selectedResidence,
					isShowingEditSheet: $isShowingEditSheet
				)
			}
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
		selectedResidence: $selected,
		isShowingEditSheet: .constant(true)
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
		selectedResidence: $selected,
		isShowingEditSheet: .constant(true)
	)
}
