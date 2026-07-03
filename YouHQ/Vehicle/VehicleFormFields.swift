//
//  VehicleFormFields.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleFormFields: View {
	enum Field: Hashable {
		case make, model, vin, url, notes
	}

	@Binding var type: VehicleType
	@Binding var subType: VehicleSubType
	@Binding var make: String
	@Binding var model: String
	@Binding var year: String
	@Binding var color: String
	@Binding var backgroundColor: Color
	@Binding var vin: String
	@Binding var costType: VehicleCostType
	@Binding var monthlyCost: Double?
	@Binding var currencyCode: String?
	@Binding var url: String
	@Binding var notes: String
	let photoPicker: PhotoPickerViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	init(
		type: Binding<VehicleType>,
		subType: Binding<VehicleSubType>,
		make: Binding<String>,
		model: Binding<String>,
		year: Binding<String>,
		color: Binding<String>,
		backgroundColor: Binding<Color>,
		vin: Binding<String>,
		costType: Binding<VehicleCostType>,
		monthlyCost: Binding<Double?>,
		currencyCode: Binding<String?>,
		url: Binding<String>,
		notes: Binding<String>,
		photoPicker: PhotoPickerViewModel,
		autoFocus: Bool = false
	) {
		_type = type
		_subType = subType
		_make = make
		_model = model
		_year = year
		_color = color
		_backgroundColor = backgroundColor
		_vin = vin
		_costType = costType
		_monthlyCost = monthlyCost
		_currencyCode = currencyCode
		_url = url
		_notes = notes
		self.photoPicker = photoPicker
		self.autoFocus = autoFocus
	}

	var body: some View {
		Section("Basic Info") {
			LabeledField("Type") {
				Picker("", selection: $type) {
					ForEach(VehicleType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				}
				.labelsHidden()
			}

			LabeledField("Subtype") {
				Picker("", selection: $subType) {
					ForEach(VehicleSubType.allCases, id: \.self) { subType in
						HQText(subType.rawValue).tag(subType)
					}
				}
				.labelsHidden()
			}
		}
		.onAppear {
			if autoFocus, !hasAppeared {
				hasAppeared = true
				focusedField = .make
			}
		}

		Section("Details") {
			TextField("Make", text: $make)
				.focused($focusedField, equals: .make)
				.onSubmit { focusedField = .model }
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Model", text: $model)
				.focused($focusedField, equals: .model)
				.onSubmit { focusedField = .vin }
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Year", text: $year)
				#if !os(macOS)
					.keyboardType(.numberPad)
				#endif

			LabeledField("Color") {
				ColorPicker(
					"",
					selection: $backgroundColor,
					supportsOpacity: false
				)
				.labelsHidden()
				.onChange(of: backgroundColor) { _, newColor in
					color = newColor.databaseValue
				}
			}

			TextField("VIN", text: $vin)
				.focused($focusedField, equals: .vin)
				.onSubmit { focusedField = .url }
				#if !os(macOS)
					.textInputAutocapitalization(.characters)
				#endif
		}

		Section("Cost") {
			LabeledField("Cost Type") {
				Picker("", selection: $costType) {
					ForEach(VehicleCostType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				}
				.labelsHidden()
			}

			if costType != .owned {
				MoneyField("Monthly Cost", amount: $monthlyCost)

				CurrencySelectorRow(currencyCode: $currencyCode)
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
