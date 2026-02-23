//
//  DeviceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct DeviceEdit: View {
	enum Field: Hashable {
		case brand, model, serialNumber, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let deviceVM = coordinator.deviceViewModel {
			@Bindable var vm = deviceVM
			Section("Device Info") {
				LabeledField("Type", shouldOverrideTap: false) {
					Picker(selection: $vm.type) {
						ForEach(DeviceType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField("Brand") {
					TextField("", text: $vm.brand)
						.focused($focusedField, equals: .brand)
						.onSubmit { focusedField = .model }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Model") {
					TextField("", text: $vm.model)
						.focused($focusedField, equals: .model)
						.onSubmit { focusedField = .serialNumber }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Serial Number") {
					TextField("", text: $vm.serialNumber)
						.focused($focusedField, equals: .serialNumber)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}

				LabeledField("Purchase Date") {
					DatePicker(
						"",
						selection: Binding(
							get: { vm.purchaseDate ?? Date() },
							set: { vm.purchaseDate = $0 }
						),
						displayedComponents: .date
					)
					.labelsHidden()
				}
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .brand
				}
			}

			Section("Website") {
				URLTextField(text: $vm.url)
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}
