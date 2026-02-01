//
//  MaintenanceItemsNavButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/13/26.
//

import SwiftUI

struct MaintenanceItemsNavButton: View {
	@Environment(\.colorScheme) var colorScheme

	@Binding var isNavigating: Bool
	let maintenanceItems: [MaintenanceItem]

	var body: some View {
		Button {
			isNavigating = true
		} label: {
			HStack {
				Image(systemName: "wrench.and.screwdriver.fill")
					.font(.title2)

				VStack(alignment: .leading, spacing: 4) {
					HQText("Maintenance Items")
						.font(.headline)

					let pastDue = maintenanceItems.filter { $0.isPastDue }.count
					let upcoming = maintenanceItems.filter { $0.isUpcoming }.count

					VStack(alignment: .leading) {
						HQText("^[\(maintenanceItems.count) item](inflect: true)")
							.font(.subheadline)
							.opacity(0.8)

						if pastDue > 0 || upcoming > 0 {
							HStack(spacing: 8) {
								if pastDue > 0 {
									HQText("\(pastDue) past due")
										.font(.subheadline)
										.badgeStyle(type: .alert)
								}

								if upcoming > 0 {
									HQText("\(upcoming) upcoming")
										.font(.subheadline)
										.badgeStyle(type: .warning)
								}
							}
						}
					}
				}

				Spacer()

				Image(systemName: "chevron.right")
					.font(.body.weight(.semibold))
					.foregroundStyle(.white.opacity(0.6))
			}
			.padding()
			#if !os(macOS)
				.background(colorScheme == .light ? .black.opacity(0.75) : Color(uiColor: UIColor.darkGray).opacity(0.8))
			#elseif os(macOS)
				.background(colorScheme == .light ? .black.opacity(0.75) : Color(nsColor: NSColor.darkGray).opacity(0.8))
			#endif
			.foregroundStyle(.white)
			.clipShape(.rect(cornerRadius: 12))
		}
		.buttonStyle(.plain)
		.padding(.bottom)
	}
}

#Preview {
	MaintenanceItemsNavButton(
		isNavigating: .constant(false),
		maintenanceItems: [MaintenanceItem.residenceSampleData, MaintenanceItem.residenceSampleData]
	)
}
