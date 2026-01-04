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
			if vm.selectedResidence != nil {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						vm.showEditResidenceSheet()
					} label: {
						Label("Edit", systemImage: "pencil")
					}
				}
			}

			ToolbarItem(placement: .topBarTrailing) {
				Button {
					vm.showCreateResidenceSheet()
				} label: {
					Label("Add Residence", systemImage: "plus")
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
