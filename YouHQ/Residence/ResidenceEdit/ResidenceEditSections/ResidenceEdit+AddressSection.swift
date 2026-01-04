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
					.apply {
						#if !os(macOS)
							$0.textInputAutocapitalization(.words)
						#endif
					}
				TextField("Unit/Apt (Optional)", text: $vm.unit)
					.textContentType(.streetAddressLine2)
					.apply {
						#if !os(macOS)
							$0.textInputAutocapitalization(.words)
						#endif
					}
				TextField("City", text: $vm.city)
					.textContentType(.addressCity)
					.apply {
						#if !os(macOS)
							$0.textInputAutocapitalization(.words)
						#endif
					}
				TextField("State", text: $vm.state)
					.textContentType(.addressState)
					.apply {
						#if !os(macOS)
							$0.textInputAutocapitalization(.characters)
						#endif
					}
				TextField("ZIP Code", text: $vm.zipCode)
					.textContentType(.postalCode)
					.apply {
						#if !os(macOS)
							$0.keyboardType(.numberPad)
						#endif
					}
				TextField("Country", text: $vm.country)
					.textContentType(.countryName)
					.apply {
						#if !os(macOS)
							$0.textInputAutocapitalization(.words)
						#endif
					}
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
