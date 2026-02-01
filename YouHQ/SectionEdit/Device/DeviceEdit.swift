//
//  DeviceEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct DeviceEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let deviceVM = coordinator.deviceViewModel {
			@Bindable var vm = deviceVM
			Section("Device Info") {
				LabeledField(label: "Type") {
					Picker(selection: $vm.type) {
						ForEach(DeviceType.allCases, id: \.self) { type in
							HQText(type.rawValue).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Brand") {
					TextField("", text: $vm.brand)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Model") {
					TextField("", text: $vm.model)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Serial Number") {
					TextField("", text: $vm.serialNumber)
						.multilineTextAlignment(.trailing)
				}

				LabeledField(label: "Purchase Date") {
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

			Section("Website") {
				URLTextField(text: $vm.url)
			}

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
			}
		}
	}
}
