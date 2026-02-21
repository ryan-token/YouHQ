//
//  PaintColorEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SwiftUI

struct PaintColorEdit: View {
	enum Field: Hashable {
		case room, manufacturer, colorName, colorCode, surfaceType, purchasedFrom, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let paintColorVM = coordinator.paintColorViewModel {
			@Bindable var vm = paintColorVM
			Section("Paint Info") {
				LabeledField(label: vm.paintColor.residenceID != nil ? "Room" : "Part of Car") {
					TextField("", text: $vm.room)
						.focused($focusedField, equals: .room)
						.onSubmit { focusedField = .manufacturer }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Manufacturer") {
					TextField("", text: $vm.manufacturer)
						.focused($focusedField, equals: .manufacturer)
						.onSubmit { focusedField = .colorName }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Color Name") {
					TextField("", text: $vm.colorName)
						.focused($focusedField, equals: .colorName)
						.onSubmit { focusedField = .colorCode }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Color Code") {
					TextField("", text: $vm.colorCode)
						.focused($focusedField, equals: .colorCode)
						.onSubmit { focusedField = .surfaceType }
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
						.focused($focusedField, equals: .surfaceType)
						.onSubmit { focusedField = .purchasedFrom }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .room
				}
			}

			Section("Purchase Details") {
				LabeledField(label: "Purchased From") {
					TextField("", text: $vm.storePurchasedFrom)
						.focused($focusedField, equals: .purchasedFrom)
						.onSubmit { focusedField = .url }
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
