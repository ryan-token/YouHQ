//
//  PaintColorEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SwiftUI

struct PaintColorEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let paintColorVM = coordinator.paintColorViewModel {
			@Bindable var vm = paintColorVM
			Section("Paint Info") {
				LabeledField(label: vm.paintColor.residenceID != nil ? "Room" : "Part of Car") {
					TextField("", text: $vm.room)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Manufacturer") {
					TextField("", text: $vm.manufacturer)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Color Name") {
					TextField("", text: $vm.colorName)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Color Code") {
					TextField("", text: $vm.colorCode)
						.multilineTextAlignment(.trailing)
				}

				LabeledField(label: "Appx Color") {
					ColorPicker(
						"Paint Color",
						selection: $vm.backgroundColor,
						supportsOpacity: false
					)
					.labelsHidden()
				}

				LabeledField(label: "Finish") {
					Picker(selection: $vm.finish) {
						ForEach(PaintFinish.allCases, id: \.self) { finish in
							HQText(finish.rawValue).tag(finish)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Surface Type") {
					TextField("", text: $vm.surfaceType)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			}

			Section("Purchase Details") {
				LabeledField(label: "Purchased From") {
					TextField("", text: $vm.storePurchasedFrom)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

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

				LabeledField(label: "Application Date") {
					DatePicker(
						"",
						selection: Binding(
							get: { vm.applicationDate ?? Date() },
							set: { vm.applicationDate = $0 }
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
