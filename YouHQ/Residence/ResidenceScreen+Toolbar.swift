//
//  ResidenceScreen+Toolbar.swift
//  YouHQ
//
//  Created by Ryan Token on 1/3/26.
//

import SQLiteData
import SwiftUI

extension ResidenceScreen {
	struct Toolbar: ToolbarContent {
		@Bindable var vm: ResidenceScreen.ViewModel
		let namespace: Namespace.ID

		var body: some ToolbarContent {
			if vm.residences.count > 1 {
				ToolbarTitleMenu {
					Picker(
						"Choose Home",
						selection: Binding(
							get: { vm.selectedResidence?.id },
							set: { newID in
								if let residence = vm.residences.first(where: { $0.id == newID }) {
									vm.selectedResidence = residence
								}
							}
						)
					) {
						ForEach(vm.residences) { residence in
							HQText(residence.unitOrStreet ?? residence.street)
								.tag(residence.id)
						}
					}
				}
			}

			AddMenuToolbarItem(showProgressViewIfSyncing: vm.residences.isEmpty, namespace: namespace) {
				ResidenceMenu(vm: vm, includeAddResidence: true)
			}
		}
	}
}

#Preview {
	struct PreviewWrapper: View {
		@Namespace private var namespace
		var body: some View {
			Form { HQText("ResidenceScreen Toolbar") }
				.toolbar { ResidenceScreen.Toolbar(vm: ResidenceScreen.ViewModel(), namespace: namespace) }
		}
	}
	return PreviewWrapper()
}
