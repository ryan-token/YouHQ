//
//  ResidenceScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SwiftUI

extension ResidenceScreen {
	struct Toolbar: ToolbarContent {
		@Bindable var vm: ResidenceScreen.ViewModel

		var body: some ToolbarContent {
			if vm.residences.count > 1 {
				ToolbarTitleMenu {
					Picker("Choose Home", selection: $vm.selectedResidenceID) {
						ForEach(vm.residences) { residence in
							Text(residence.unitOrStreet ?? residence.street)
								.tag(residence.id.uuidString)
						}
					}
				}
			}

			ToolbarItem(placement: .primaryAction) {
				Menu {
					ResidenceMenu(vm: vm, includeAddResidence: true)
				} label: {
					Label("Add", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	Form {
		Text("ResidenceScreen Toolbar")
	}
	.toolbar { ResidenceScreen.Toolbar(vm: ResidenceScreen.ViewModel()) }
}
