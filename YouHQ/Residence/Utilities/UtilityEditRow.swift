//
//  UtilityEditRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/2/26.
//

import SQLiteData
import SwiftUI

struct UtilityEditRow: View {
	@State private var vm: ViewModel

	init(utility: Utility) {
		_vm = State(wrappedValue: ViewModel(utility: utility))
	}

	var body: some View {
		Section(vm.utility.type.rawValue) {
			TextField("Provider", text: $vm.provider)
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif
			TextField("Account Number", text: $vm.accountNumber)
			TextField(
				"Monthly Cost",
				value: Binding(
					get: { vm.approximateMonthlyCost ?? 0 },
					set: { vm.approximateMonthlyCost = $0 }
				),
				format: .number
			)
			#if !os(macOS)
				.keyboardType(.decimalPad)
			#endif

			URLTextField(text: $vm.url)

			TextField("Notes", text: $vm.notes, axis: .vertical)
				.lineLimit(3...6)
		}
	}
}

extension UtilityEditRow {
	@Observable
	class ViewModel {
		@ObservationIgnored
		@Dependency(\.defaultDatabase) var database

		let utility: Utility

		var provider: String {
			didSet { saveChanges() }
		}
		var accountNumber: String {
			didSet { saveChanges() }
		}
		var approximateMonthlyCost: Double? {
			didSet { saveChanges() }
		}
		var url: String {
			didSet { saveChanges() }
		}
		var notes: String {
			didSet { saveChanges() }
		}

		init(utility: Utility) {
			self.utility = utility
			provider = utility.provider
			accountNumber = utility.accountNumber
			approximateMonthlyCost = utility.approximateMonthlyCost
			url = utility.url
			notes = utility.notes
		}

		private func saveChanges() {
			withErrorReporting {
				try database.write { db in
					try Utility.find(utility.id)
						.update {
							$0.provider = provider
							$0.accountNumber = accountNumber
							$0.approximateMonthlyCost = approximateMonthlyCost
							$0.url = url
							$0.notes = notes
						}
						.execute(db)
				}
			}
		}
	}
}

#Preview {
	Form {
		UtilityEditRow(utility: Utility.sampleData)
	}
}
