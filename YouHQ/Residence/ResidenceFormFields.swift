//
//  ResidenceFormFields.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import SwiftUI

struct ResidenceFormFields: View {
	@Binding var type: ResidenceType
	@Binding var isCurrent: Bool
	@Binding var street: String
	@Binding var unit: String
	@Binding var city: String
	@Binding var state: String
	@Binding var zipCode: String
	@Binding var country: String
	@Binding var moveInDate: Date?
	@Binding var moveOutDate: Date?
	@Binding var hasMoveOutDate: Bool
	@Binding var costType: ResidenceCostType
	@Binding var monthlyCost: Double?
	@Binding var url: String
	@Binding var notes: String
	let photoPicker: PhotoPickerViewModel
	var focusedField: FocusState<Bool>.Binding?

	init(
		type: Binding<ResidenceType>,
		isCurrent: Binding<Bool>,
		street: Binding<String>,
		unit: Binding<String>,
		city: Binding<String>,
		state: Binding<String>,
		zipCode: Binding<String>,
		country: Binding<String>,
		moveInDate: Binding<Date?>,
		moveOutDate: Binding<Date?>,
		hasMoveOutDate: Binding<Bool>,
		costType: Binding<ResidenceCostType>,
		monthlyCost: Binding<Double?>,
		url: Binding<String>,
		notes: Binding<String>,
		photoPicker: PhotoPickerViewModel,
		focusedField: FocusState<Bool>.Binding? = nil
	) {
		_type = type
		_isCurrent = isCurrent
		_street = street
		_unit = unit
		_city = city
		_state = state
		_zipCode = zipCode
		_country = country
		_moveInDate = moveInDate
		_moveOutDate = moveOutDate
		_hasMoveOutDate = hasMoveOutDate
		_costType = costType
		_monthlyCost = monthlyCost
		_url = url
		_notes = notes
		self.photoPicker = photoPicker
		self.focusedField = focusedField
	}

	var body: some View {
		Section("Basic Info") {
			LabeledField(label: "Type") {
				Picker(selection: $type) {
					ForEach(ResidenceType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			LabeledField(label: "Current Residence") {
				Toggle("", isOn: $isCurrent)
					.labelsHidden()
			}
		}

		Section("Address") {
			TextField("Street", text: $street)
				.focused(focusedField ?? FocusState<Bool>().projectedValue)
				#if !os(macOS)
					.textContentType(.streetAddressLine1)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Unit", text: $unit)
				#if !os(macOS)
					.textContentType(.streetAddressLine2)
					.textInputAutocapitalization(.words)
				#endif
			TextField("City", text: $city)
				#if !os(macOS)
					.textContentType(.addressCity)
					.textInputAutocapitalization(.words)
				#endif
			TextField("State", text: $state)
				#if !os(macOS)
					.textContentType(.addressState)
					.textInputAutocapitalization(.characters)
				#endif
			TextField("ZIP Code", text: $zipCode)
				#if !os(macOS)
					.textContentType(.postalCode)
					.keyboardType(.numberPad)
				#endif
			TextField("Country", text: $country)
				#if !os(macOS)
					.textContentType(.countryName)
					.textInputAutocapitalization(.words)
				#endif
		}

		Section("Dates") {
			LabeledField(label: "Move-in Date") {
				DatePicker(
					"",
					selection: Binding(
						get: { moveInDate ?? Date() },
						set: { moveInDate = $0 }
					),
					displayedComponents: .date
				)
				.labelsHidden()
			}

			LabeledField(label: "Has Move-out Date") {
				Toggle("", isOn: $hasMoveOutDate)
					.labelsHidden()
			}

			if hasMoveOutDate {
				LabeledField(label: "Move-out Date") {
					DatePicker(
						"",
						selection: Binding(
							get: { moveOutDate ?? Date() },
							set: { moveOutDate = $0 }
						),
						displayedComponents: .date
					)
					.labelsHidden()
				}
			}
		}

		Section("Cost") {
			LabeledField(label: "Cost Type") {
				Picker(selection: $costType) {
					ForEach(ResidenceCostType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			if costType != .owned {
				LabeledField(label: "Monthly Cost") {
					TextField(
						"",
						value: $monthlyCost,
						format: .currency(code: "USD")
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.keyboardType(.decimalPad)
				#endif
			}
		}

		Section("Website") {
			URLTextField(text: $url)
		}

		PhotoPickerSection(
			title: "Image",
			viewModel: photoPicker
		)

		Section("Notes") {
			TextEditor(text: $notes)
				.frame(minHeight: 100)
				.scrollContentBackground(.hidden)
		}
	}
}
