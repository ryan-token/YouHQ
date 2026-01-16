//
//  ResidenceFormFields.swift
//  YouHQ
//
//  Created by Ryan Token on 1/12/26.
//

import PhotosUI
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
	@Binding var costType: CostType
	@Binding var monthlyCost: Double?
	@Binding var url: String
	@Binding var notes: String
	@Binding var photoData: Data?
	@Binding var photoItem: PhotosPickerItem?
	@Binding var viewerPayload: PhotoViewerPayload?
	let onPhotoItemChange: (PhotosPickerItem?) -> Void
	let onRemovePhoto: () -> Void
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
		costType: Binding<CostType>,
		monthlyCost: Binding<Double?>,
		url: Binding<String>,
		notes: Binding<String>,
		photoData: Binding<Data?>,
		photoItem: Binding<PhotosPickerItem?>,
		viewerPayload: Binding<PhotoViewerPayload?>,
		onPhotoItemChange: @escaping (PhotosPickerItem?) -> Void,
		onRemovePhoto: @escaping () -> Void,
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
		_photoData = photoData
		_photoItem = photoItem
		_viewerPayload = viewerPayload
		self.onPhotoItemChange = onPhotoItemChange
		self.onRemovePhoto = onRemovePhoto
		self.focusedField = focusedField
	}

	var body: some View {
		Section("Basic Info") {
			LabeledField(label: "Type") {
				Picker(selection: $type) {
					ForEach(ResidenceType.allCases, id: \.self) { type in
						Text(type.rawValue).tag(type)
					}
				} label: {
					EmptyView()
				}
			}

			Toggle("Current Residence", isOn: $isCurrent)
		}

		Section("Address") {
			TextField("Street", text: $street)
				.focused(focusedField ?? FocusState<Bool>().projectedValue)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Unit", text: $unit)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("City", text: $city)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("State", text: $state)
				#if !os(macOS)
					.textInputAutocapitalization(.characters)
				#endif
			TextField("ZIP Code", text: $zipCode)
				#if !os(macOS)
					.keyboardType(.numberPad)
				#endif
			TextField("Country", text: $country)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
		}

		Section("Dates") {
			DatePicker(
				"Move-in Date",
				selection: Binding(
					get: { moveInDate ?? Date() },
					set: { moveInDate = $0 }
				),
				displayedComponents: .date
			)

			Toggle("Has Move-out Date", isOn: $hasMoveOutDate)

			if hasMoveOutDate {
				DatePicker(
					"Move-out Date",
					selection: Binding(
						get: { moveOutDate ?? Date() },
						set: { moveOutDate = $0 }
					),
					displayedComponents: .date
				)
			}
		}

		Section("Cost") {
			LabeledField(label: "Cost Type") {
				Picker(selection: $costType) {
					ForEach(CostType.allCases, id: \.self) { type in
						Text(type.rawValue).tag(type)
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
			title: "Photo",
			photoData: $photoData,
			photoItem: $photoItem,
			viewerPayload: $viewerPayload,
			onPhotoItemChange: onPhotoItemChange,
			onRemove: onRemovePhoto
		)

		Section("Notes") {
			TextEditor(text: $notes)
				.frame(minHeight: 100)
				.scrollContentBackground(.hidden)
		}
	}
}
