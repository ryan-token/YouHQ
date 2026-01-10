//
//  ResidenceEdit+URLSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

extension ResidenceEdit {
	struct URLSection: View {
		@Bindable var vm: ViewModel

		var body: some View {
			Section("Website") {
				URLTextField(text: $vm.url)
			}
		}
	}
}

#Preview {
	Form {
		ResidenceEdit.URLSection(
			vm: ResidenceEdit.ViewModel(
				residence: nil,
				profileID: UUID()
			)
		)
	}
}
