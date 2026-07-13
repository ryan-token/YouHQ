//
//  BankAccountSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct BankAccountSection: View {
	let account: BankAccount
	let hideAccountNumbers: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			"\(account.accountType.rawValue) Account",
			backgroundColor: Color(databaseValue: account.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if account.bankName.isNotEmpty {
				HQText(account.bankName)
					.sectionTitle()
			}

			if account.accountNumber.isNotEmpty {
				InfoRow(
					"Account number:",
					value: account.accountNumber,
					blurred: hideAccountNumbers
				)
			}

			if account.routingNumber.isNotEmpty {
				InfoRow(
					"Routing number:",
					value: account.routingNumber,
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
					HQText("Notes:")
						.font(.headline)
					HQText(account.notes)
				}
			}
		}
	}
}
