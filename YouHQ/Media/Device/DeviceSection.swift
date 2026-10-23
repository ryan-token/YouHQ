//
//  DeviceSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct DeviceSection: View {
	let device: Device
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	/// "Brand Model", skipping whichever part is empty.
	private var title: String {
		[device.brand, device.model]
			.filter(\.isNotEmpty)
			.joined(separator: " ")
	}

	var body: some View {
		InfoSection(
			device.type.rawValue,
			backgroundColor: Color(databaseValue: device.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if title.isNotEmpty {
				HQText(title)
					.sectionTitle()
			}

			if device.serialNumber.isNotEmpty {
				InfoRow("Serial number:", value: device.serialNumber)
			}

			if let purchaseDate = device.purchaseDate {
				InfoRow(
					"Purchase date:",
					value: purchaseDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			if device.url.isNotEmpty {
				LinkRow("Website:", url: device.url)
			}

			if device.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
					HQText(device.notes)
				}
			}
		}
	}
}

#Preview {
	DeviceSection(
		device: Device(
			id: UUID(),
			profileID: UUID(),
			type: .computer,
			brand: "Apple",
			model: "MacBook Pro",
			serialNumber: "C02ABC123DEF",
			purchaseDate: .now,
			backgroundColor: "pink",
			url: "https://apple.com",
			notes: "Work laptop"
		),
		onColorChange: { _ in },
		onTap: nil
	)
}
