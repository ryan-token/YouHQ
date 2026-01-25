//
//  HealthSavingsAccountSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct HealthSavingsAccountSection: View {
	let account: HealthSavingsAccount
	let hideAccountNumbers: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			account.accountType.rawValue,
			backgroundColor: Color(databaseValue: account.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if account.institution.isNotEmpty {
				Text(account.institution)
					.sectionTitle()
			}

			if account.accountNumber.isNotEmpty {
				InfoRow(
					"Account number:",
					value: account.accountNumber,
					blurred: hideAccountNumbers
				)
			}

			if !account.isActive {
				InfoRow("Status:", value: "Inactive")
			}

			if account.url.isNotEmpty {
				LinkRow("Website:", url: account.url)
			}

			if account.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					Text(account.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}
