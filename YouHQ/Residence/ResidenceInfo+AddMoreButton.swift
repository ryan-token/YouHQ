//
//  ResidenceInfo+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

extension ResidenceInfo {
	struct AddMoreButton: View {
		let vm: ResidenceScreen.ViewModel

		var body: some View {
			Menu {
				Button {
					vm.showAddUtilitySheet()
				} label: {
					Label("Add Utility", systemImage: "bolt.fill")
				}

				Button {
					vm.showAddInsurancePolicySheet()
				} label: {
					Label(
						"Add Insurance Policy",
						systemImage: "shield.fill"
					)
				}
			} label: {
				HStack {
					Image(systemName: "plus.circle.fill")
						.font(.title2)
					Text("Add More")
						.font(.headline)
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.ultraThinMaterial)
				.clipShape(.rect(cornerRadius: 12))
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	ResidenceInfo.AddMoreButton(vm: ResidenceScreen.ViewModel())
}
