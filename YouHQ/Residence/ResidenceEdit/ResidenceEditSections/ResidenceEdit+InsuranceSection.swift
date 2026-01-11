//
//  ResidenceEdit+InsuranceSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

extension ResidenceEdit {
	struct InsuranceSection: View {
		@Bindable var vm: ResidenceEdit.ViewModel

		var body: some View {
			Section("Insurance") {
				if vm.insurancePolicies.isEmpty {
					Text("No insurance policies added yet")
						.foregroundStyle(.secondary)
				} else {
					ForEach(vm.insurancePolicies) { policy in
						NavigationLink {
							Form {
								InsuranceEditRow(policy: policy)
							}
							.navigationTitle(policy.type.rawValue)
							#if !os(macOS)
								.navigationBarTitleDisplayMode(.inline)
							#endif
						} label: {
							HStack {
								Text(policy.type.rawValue)
								Spacer()
								if policy.provider.isNotEmpty {
									Text(policy.provider)
										.foregroundStyle(.secondary)
								}
							}
						}
					}
					.onDelete { offsets in
						for index in offsets {
							vm.deleteInsurancePolicy(
								vm.insurancePolicies[index]
							)
						}
					}
				}

				Menu {
					Button("Home") {
						if let residenceID = vm.residenceID {
							vm.addInsurancePolicy(
								type: .home,
								residenceID: residenceID
							)
						}
					}

					Button("Renters") {
						if let residenceID = vm.residenceID {
							vm.addInsurancePolicy(
								type: .renters,
								residenceID: residenceID
							)
						}
					}
					.task {
						if let newResidence = vm.save() {
							print("saving residence")
							vm.residenceID = newResidence.id
							await vm.loadInsurancePolicies(for: newResidence.id)
						}
					}
				} label: {
					Label("Add Insurance", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.InsuranceSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
