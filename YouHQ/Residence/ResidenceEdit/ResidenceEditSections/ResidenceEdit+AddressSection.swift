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
				TextField("Street", text: $vm.street)
					.textContentType(.streetAddressLine1)
					#if !os(macOS)
						.textInputAutocapitalization(.words)
					#endif
				TextField("Unit/Apt", text: $vm.unit)
					.textContentType(.streetAddressLine2)
					#if !os(macOS)
						.textInputAutocapitalization(.words)
					#endif
				TextField("City", text: $vm.city)
					.textContentType(.addressCity)
					#if !os(macOS)
						.textInputAutocapitalization(.words)
					#endif
				TextField("State", text: $vm.state)
					.textContentType(.addressState)
					#if !os(macOS)
						.textInputAutocapitalization(.characters)
					#endif
				TextField("ZIP Code", text: $vm.zipCode)
					.textContentType(.postalCode)
					#if !os(macOS)
						.keyboardType(.numberPad)
					#endif
				TextField("Country", text: $vm.country)
					.textContentType(.countryName)
					#if !os(macOS)
						.textInputAutocapitalization(.words)
					#endif
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
