//
//  MaintenanceItemsNavigationLink.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct MaintenanceItemsNavigationLink: View {
	let residenceID: UUID
	let maintenanceItems: [MaintenanceItem]

	var body: some View {
		HStack {
			Image(systemName: "wrench.and.screwdriver.fill")
				.font(.title2)

			VStack(alignment: .leading, spacing: 4) {
				Text("Maintenance Items")
					.font(.headline)
					.foregroundStyle(.primary)

				let pastDue = maintenanceItems.filter { $0.isPastDue }.count
				let upcoming = maintenanceItems.filter { $0.isUpcoming }.count

				if pastDue > 0 || upcoming > 0 {
					HStack(spacing: 8) {
						if pastDue > 0 {
							Text("\(pastDue) past due")
								.font(.subheadline)
								.foregroundStyle(.red)
						}
						if upcoming > 0 {
							if pastDue > 0 {
								Text("•")
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
							Text("\(upcoming) upcoming")
								.font(.subheadline)
								.foregroundStyle(.secondary)
						}
					}
				}
			}

			Spacer()
		}
		.overlay(NavigationLink(destination: MaintenanceItemsScreen(residenceID: residenceID), label: {
			EmptyView()
		}))
		.padding()
		.background(.ultraThinMaterial)
		.clipShape(.rect(cornerRadius: 12))
	}
}
