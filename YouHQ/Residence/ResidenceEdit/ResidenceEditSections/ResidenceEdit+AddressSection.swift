//
//  ResidenceEdit+AddressSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct AddressSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Address") {
				TextField("Street Address", text: $vm.street)
					.textContentType(.streetAddressLine1)
					.textInputAutocapitalization(.words)
				TextField("Unit/Apt (Optional)", text: $vm.unit)
					.textContentType(.streetAddressLine2)
					.textInputAutocapitalization(.words)
				TextField("City", text: $vm.city)
					.textContentType(.addressCity)
					.textInputAutocapitalization(.words)
				TextField("State", text: $vm.state)
					.textContentType(.addressState)
					.textInputAutocapitalization(.characters)
				TextField("ZIP Code", text: $vm.zipCode)
					.textContentType(.postalCode)
					.keyboardType(.numberPad)
				TextField("Country", text: $vm.country)
					.textContentType(.countryName)
					.textInputAutocapitalization(.words)
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.AddressSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
