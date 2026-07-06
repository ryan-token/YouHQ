//
//  VehicleInfoSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

struct VehicleInfoSection: View {
	let vehicle: Vehicle
	let insurancePolicies: [InsurancePolicy]
	let others: [Other]
	let hideCosts: Bool
	let backgroundColor: Color
	let onTap: ((Vehicle) -> Void)?
	let onColorChange: (Color) -> Void
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

	private var resolvedCurrencyCode: String {
		Currency.resolved(vehicle.currencyCode, default: defaultCurrencyCode)
	}

	init(
		vehicle: Vehicle,
		insurancePolicies: [InsurancePolicy],
		others: [Other],
		hideCosts: Bool = false,
		backgroundColor: Color,
		onTap: ((Vehicle) -> Void)? = nil,
		onColorChange: @escaping (Color) -> Void
	) {
		self.vehicle = vehicle
		self.insurancePolicies = insurancePolicies
		self.others = others
		self.hideCosts = hideCosts
		self.backgroundColor = backgroundColor
		self.onTap = onTap
		self.onColorChange = onColorChange
	}

	private var costLineItems: [CostLineItem] {
		var items: [CostLineItem] = []

		if let vehicleCost = vehicle.monthlyCost, vehicle.costType != .owned {
			items.append(CostLineItem(label: vehicle.costType.rawValue, cost: vehicleCost))
		}

		for policy in insurancePolicies {
			if let cost = policy.monthlyCost {
				items.append(CostLineItem(label: "\(policy.type.rawValue) Insurance", cost: cost))
			}
		}

		for other in others {
			if let cost = other.monthlyCost {
				items.append(CostLineItem(label: other.name, cost: cost))
			}
		}

		return items
	}

	private var totalMonthlyCost: Double {
		costLineItems.reduce(0) { $0 + $1.cost }
	}

	var body: some View {
		InfoSection(
			"Info",
			backgroundColor: backgroundColor,
			onColorChange: onColorChange,
			onTap: {
				onTap?(vehicle)
			}
		) {
			HQText(vehicleDisplayName)
				.sectionTitle()

			if vehicle.type != .car || vehicle.subType != .gas {
				InfoRow(
					"Type:",
					value: "\(vehicle.type.rawValue) (\(vehicle.subType.rawValue))"
				)
			}

			if let vin = vehicle.vin, vin.isNotEmpty {
				InfoRow("VIN:", value: vin)
			}

			if let monthlyCost = vehicle.monthlyCost,
				vehicle.costType != .owned
			{
				InfoRow(
					"Monthly \(vehicle.costType.rawValue.lowercased()):",
					value: monthlyCost.formatted(currencyCode: resolvedCurrencyCode),
					blurred: hideCosts
				)
			}

			if totalMonthlyCost > 0 {
				MonthlyCostRow(
					"Monthly TCO:",
					totalCost: totalMonthlyCost,
					currencyCode: resolvedCurrencyCode,
					blurred: hideCosts
				) {
					CostBreakdownView(
						title: "Monthly Total Cost of Ownership",
						lineItems: costLineItems,
						totalCost: totalMonthlyCost,
						currencyCode: resolvedCurrencyCode
					)
				}
			}

			if vehicle.url.isNotEmpty {
				LinkRow("Website:", url: vehicle.url)
			}

			if vehicle.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
					HQText(vehicle.notes)
				}
			}
		}
	}

	private var vehicleDisplayName: String {
		var parts: [String] = []
		if let year = vehicle.year, year.isNotEmpty {
			parts.append(year)
		}
		if vehicle.make.isNotEmpty {
			parts.append(vehicle.make)
		}
		if vehicle.model.isNotEmpty {
			parts.append(vehicle.model)
		}
		return parts.isEmpty ? "Vehicle" : parts.joined(separator: " ")
	}
}

#Preview {
	VehicleInfoSection(
		vehicle: Vehicle(
			id: UUID(),
			profileID: UUID(),
			type: .car,
			subType: .gas,
			make: "Toyota",
			model: "Camry",
			year: "2023",
			color: "Blue",
			vin: "1HGBH41JXMN109186",
			monthlyCost: 450.00,
			costType: .loanPayment,
			backgroundColor: "teal",
			url: "",
			notes: "Great car!"
		),
		insurancePolicies: [
			InsurancePolicy(
				id: UUID(),
				profileID: UUID(),
				residenceID: nil,
				vehicleID: UUID(),
				type: .auto,
				provider: "State Farm",
				policyNumber: "123456",
				monthlyCost: 150.00,
				deductible: nil,
				coverageAmount: nil,
				startDate: nil,
				renewalDate: nil,
				isActive: true,
				backgroundColor: "red",
				url: "",
				notes: ""
			)
		],
		others: [],
		hideCosts: false,
		backgroundColor: .teal,
		onTap: nil,
		onColorChange: { _ in }
	)
}
