//
//  VehicleFormFields.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct VehicleFormFields: View {
	@Binding var type: VehicleType
	@Binding var subType: VehicleSubType
	@Binding var make: String
	@Binding var model: String
	@Binding var year: String
	@Binding var color: String
	@Binding var vin: String
	@Binding var costType: VehicleCostType
	@Binding var monthlyCost: Double?
	@Binding var url: String
	@Binding var notes: String
	let photoPicker: PhotoPickerViewModel
	var focusedField: FocusState<Bool>.Binding?

	init(
		type: Binding<VehicleType>,
		subType: Binding<VehicleSubType>,
		make: Binding<String>,
		model: Binding<String>,
		year: Binding<String>,
		color: Binding<String>,
		vin: Binding<String>,
		costType: Binding<VehicleCostType>,
		monthlyCost: Binding<Double?>,
		url: Binding<String>,
		notes: Binding<String>,
		photoPicker: PhotoPickerViewModel,
		focusedField: FocusState<Bool>.Binding? = nil
	) {
		_type = type
		_subType = subType
		_make = make
		_model = model
		_year = year
		_color = color
		_vin = vin
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
					ForEach(VehicleType.allCases, id: \.self) { type in
						HQText(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			LabeledField(label: "Subtype") {
				Picker(selection: $subType) {
					ForEach(VehicleSubType.allCases, id: \.self) { subType in
						HQText(subType.rawValue).tag(subType)
					}
				} label: {
					EmptyView()
				}
			}
		}

		Section("Details") {
			TextField("Make", text: $make)
				.focused(focusedField ?? FocusState<Bool>().projectedValue)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Model", text: $model)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Year", text: $year)
				#if !os(macOS)
					.keyboardType(.numberPad)
				#endif
			TextField("Color", text: $color)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("VIN", text: $vin)
				#if !os(macOS)
					.textInputAutocapitalization(.characters)
				#endif
		}

		Section("Cost") {
			LabeledField(label: "Cost Type") {
				Picker(selection: $costType) {
					ForEach(VehicleCostType.allCases, id: \.self) { type in
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
