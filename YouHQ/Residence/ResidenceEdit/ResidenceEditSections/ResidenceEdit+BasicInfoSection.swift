//
//  ResidenceEdit+BasicInfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceEdit {
	struct BasicInfoSection: View {
		@Bindable var vm: ViewModel

		var body: some View {
			Section("Basic Info") {
				Picker("Type", selection: $vm.type) {
					ForEach(ResidenceType.allCases, id: \.self) { type in
						Text(type.rawValue).tag(type)
					}
				}

				Toggle("Current Residence", isOn: $vm.isCurrent)
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.BasicInfoSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
