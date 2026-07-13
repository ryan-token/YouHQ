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

	var body: some View {
		InfoSection(
			device.type.rawValue,
			backgroundColor: Color(databaseValue: device.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if device.brand.isNotEmpty || device.model.isNotEmpty {
				let title = [device.brand, device.model]
					.filter { $0.isNotEmpty }
					.joined(separator: " ")
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
			purchaseDate: Date(),
			backgroundColor: "pink",
			url: "https://apple.com",
			notes: "Work laptop"
		),
		onColorChange: { _ in },
		onTap: nil
	)
}
