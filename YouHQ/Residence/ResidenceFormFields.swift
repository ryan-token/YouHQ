//
//  ResidenceFormFields.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import SwiftUI

struct ResidenceFormFields: View {
	enum Field: Hashable {
		case street, unit, city, state, country, url, notes
	}

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
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

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
		autoFocus: Bool = false
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
		self.autoFocus = autoFocus
	}

	var body: some View {
		Section("Basic Info") {
			LabeledField("Type") {
				Picker("", selection: $type) {
					ForEach(ResidenceType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				}
				.labelsHidden()
			}

			LabeledField("Current Residence") {
				Toggle("", isOn: $isCurrent)
					.labelsHidden()
			}
		}
		.onAppear {
			if autoFocus, !hasAppeared {
				hasAppeared = true
				focusedField = .street
			}
		}

		Section("Address") {
			TextField("Street", text: $street)
				.focused($focusedField, equals: .street)
				.onSubmit { focusedField = .unit }
				#if !os(macOS)
					.textContentType(.streetAddressLine1)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Unit", text: $unit)
				.focused($focusedField, equals: .unit)
				.onSubmit { focusedField = .city }
				#if !os(macOS)
					.textContentType(.streetAddressLine2)
					.textInputAutocapitalization(.words)
				#endif
			TextField("City", text: $city)
				.focused($focusedField, equals: .city)
				.onSubmit { focusedField = .state }
				#if !os(macOS)
					.textContentType(.addressCity)
					.textInputAutocapitalization(.words)
				#endif
			TextField("State/Region", text: $state)
				.focused($focusedField, equals: .state)
				.onSubmit { focusedField = .country }
				#if !os(macOS)
					.textContentType(.addressState)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Postal Code", text: $zipCode)
				#if !os(macOS)
					.textContentType(.postalCode)
					.keyboardType(.numberPad)
				#endif
			TextField("Country", text: $country)
				.focused($focusedField, equals: .country)
				.onSubmit { focusedField = .url }
				#if !os(macOS)
					.textContentType(.countryName)
					.textInputAutocapitalization(.words)
				#endif
		}

		Section("Dates") {
			LabeledField("Move-in Date") {
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

			LabeledField("Has Move-out Date") {
				Toggle("", isOn: $hasMoveOutDate)
					.labelsHidden()
			}

			if hasMoveOutDate {
				LabeledField("Move-out Date") {
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
			LabeledField("Cost Type") {
				Picker("", selection: $costType) {
					ForEach(ResidenceCostType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				}
				.labelsHidden()
			}

			if costType != .owned {
				LabeledField("Monthly Cost") {
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
				.focused($focusedField, equals: .url)
				.onSubmit { focusedField = .notes }
		}

		PhotoPickerSection(
			title: "Image",
			viewModel: photoPicker
		)

		Section("Notes") {
			TextField("Notes", text: $notes, axis: .vertical)
				.lineLimit(5...)
				.focused($focusedField, equals: .notes)
				.onSubmit { focusedField = nil }
		}
	}
}
