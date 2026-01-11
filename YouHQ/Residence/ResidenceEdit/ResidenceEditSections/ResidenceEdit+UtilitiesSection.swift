//
//  ResidenceEdit+UtilitiesSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct UtilitiesSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Utilities") {
				if vm.utilities.isEmpty {
					Text("No utilities added yet")
						.foregroundStyle(.secondary)
				} else {
					ForEach(vm.utilities) { utility in
						NavigationLink {
							Form {
								UtilityEditRow(utility: utility)
							}
							.navigationTitle(utility.type.rawValue)
							#if !os(macOS)
								.navigationBarTitleDisplayMode(.inline)
							#endif
						} label: {
							HStack {
								Text(utility.type.rawValue)
								Spacer()
								if utility.provider.isNotEmpty {
									Text(utility.provider)
										.foregroundStyle(.secondary)
								}
							}
						}
					}
					.onDelete { offsets in
						for index in offsets {
							vm.deleteUtility(vm.utilities[index])
						}
					}
				}

				Menu {
					ForEach(UtilityType.allCases, id: \.self) { type in
						Button(type.rawValue) {
							if let residenceID = vm.residenceID {
								vm.addUtility(
									type: type,
									residenceID: residenceID
								)
							}
						}
					}
					.task {
						if let newResidence = vm.save() {
							print("saving residence")
							vm.residenceID = newResidence.id
							await vm.loadUtilities(for: newResidence.id)
						}
					}
				} label: {
					Label("Add Utility", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.UtilitiesSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
