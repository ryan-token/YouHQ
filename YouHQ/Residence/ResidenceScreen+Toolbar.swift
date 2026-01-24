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
		@Dependency(\.defaultSyncEngine) var syncEngine
		@Bindable var vm: ResidenceScreen.ViewModel

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
							Text(residence.unitOrStreet ?? residence.street)
								.tag(residence.id)
						}
					}
				}
			}

			#if !os(macOS)
				ToolbarItem(placement: .primaryAction) {
					Button {
						Task { await vm.shareResidenceTapped() }
					} label: {
						Image(systemName: "square.and.arrow.up")
					}
					.sheet(item: $vm.sharedRecord) { sharedRecord in
						CloudSharingView(sharedRecord: sharedRecord)
					}
				}
			#endif

			if vm.residences.isEmpty && syncEngine.isSynchronizing {
				ToolbarItem(placement: .primaryAction) {
					ProgressView()
				}
			} else {
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
}

#Preview {
	Form {
		Text("ResidenceScreen Toolbar")
	}
	.toolbar { ResidenceScreen.Toolbar(vm: ResidenceScreen.ViewModel()) }
}
