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

	var totalMonthlyCost: Double {
		var total: Double = 0

		// Add vehicle monthly cost (payment) - but not if owned
		if let vehicleCost = vehicle.monthlyCost,
			vehicle.costType != .owned
		{
			total += vehicleCost
		}

		// Add insurance policy costs
		for policy in insurancePolicies {
			if let policyCost = policy.monthlyCost {
				total += policyCost
			}
		}

		// Add other costs
		for other in others {
			if let otherCost = other.monthlyCost {
				total += otherCost
			}
		}

		return total
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

			if let color = vehicle.color, color.isNotEmpty {
				InfoRow("Color:", value: color)
			}

			if let vin = vehicle.vin, vin.isNotEmpty {
				InfoRow("VIN:", value: vin)
			}

			if let monthlyCost = vehicle.monthlyCost,
				vehicle.costType != .owned
			{
				InfoRow(
					"Monthly \(vehicle.costType.rawValue.lowercased()):",
					value: "\(monthlyCost.asCost)",
					blurred: hideCosts
				)
			}

			if totalMonthlyCost > 0 {
				VehicleMonthlyCostRow(
					"Monthly TCO:",
					totalCost: totalMonthlyCost,
					vehicleCost: vehicle.monthlyCost,
					vehicleCostType: vehicle.costType,
					insurancePolicies: insurancePolicies,
					others: others,
					blurred: hideCosts
				)
			}

			if vehicle.url.isNotEmpty {
				LinkRow("Website:", url: vehicle.url)
			}

			if vehicle.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					HQText("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					HQText(vehicle.notes)
						.foregroundStyle(.white)
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
