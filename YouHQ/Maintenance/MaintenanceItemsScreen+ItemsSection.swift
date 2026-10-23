//
//  MaintenanceItemsScreen+ItemsSection.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension MaintenanceItemsScreen {
	/// One due-date group of maintenance items, with swipe-to-delete.
	struct ItemsSection: View {
		let title: String
		let items: [MaintenanceItem]
		let vm: ViewModel
		let namespace: Namespace.ID

		var body: some View {
			Section(title) {
				ForEach(items) { item in
					MaintenanceItemRow(
						item: item,
						onTap: { vm.editMaintenanceItem(item) },
						onComplete: { vm.showCompleteAlert(for: item) }
					)
					.matchedTransitionSource(id: item.id.uuidString, in: namespace)
				}
				.onDelete(perform: delete)
			}
		}

		private func delete(at offsets: IndexSet) {
			vm.deleteMaintenanceItems(at: offsets, from: items)
		}
	}
}
