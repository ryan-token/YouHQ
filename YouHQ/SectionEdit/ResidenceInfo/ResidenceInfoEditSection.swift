//
//  ResidenceInfoEditSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct ResidenceInfoEditSection: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let residenceVM = coordinator.residenceViewModel {
			@Bindable var vm = residenceVM
			ResidenceFormFields(
				type: $vm.residenceType,
				isCurrent: $vm.isCurrent,
				street: $vm.street,
				unit: $vm.unit,
				city: $vm.city,
				state: $vm.state,
				zipCode: $vm.zipCode,
				country: $vm.country,
				moveInDate: $vm.moveInDate,
				moveOutDate: $vm.moveOutDate,
				hasMoveOutDate: $vm.hasMoveOutDate,
				costType: $vm.costType,
				monthlyCost: $vm.monthlyCost,
				showURLAndNotes: true,
				url: $vm.url,
				notes: $vm.notes,
				focusedField: focusedField
			)
		}
	}
}

#Preview("Residence Info") {
	SectionEditSheet(section: .residenceInfo(Residence.sampleData))
}
