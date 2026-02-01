//
//  MaintenanceItemRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct MaintenanceItemRow: View {
	let item: MaintenanceItem
	let onTap: () -> Void
	let onComplete: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .top, spacing: 12) {
				VStack(alignment: .leading, spacing: 4) {
					HQText(item.name)
						.font(.headline)

					if item.itemDescription.isNotEmpty {
						HQText(item.itemDescription)
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.lineLimit(2)
					}

					HStack(spacing: 4) {
						Text(
							"Every ^[\(item.intervalValue) \(item.intervalType.rawValue.lowercased())](inflect: true)"
						)
						.font(.caption)
						.fontDesign(.rounded)
						.foregroundStyle(.secondary)

						HQText("•")
							.font(.caption)
							.foregroundStyle(.secondary)

						if let nextDue = item.dueDate {
							Text("Due \(nextDue, style: .date)")
								.font(.caption)
								.fontDesign(.rounded)
								.foregroundStyle(
									item.isPastDue ? .red : .secondary
								)
						} else {
							HQText("No due date set")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
				}

				Spacer()

				Button(action: onComplete) {
					Image(systemName: "checkmark.circle")
						.font(.title2)
						.foregroundStyle(.green)
				}
				.buttonStyle(.plain)
			}
			.padding(.vertical, 4)
		}
		.contentShape(.rect)
		.foregroundStyle(.primary)
		#if os(macOS)
			.listRowSeparator(.hidden)
		#endif
	}
}

#Preview {
	MaintenanceItemRow(item: MaintenanceItem.residenceSampleData, onTap: {}, onComplete: {})
}
