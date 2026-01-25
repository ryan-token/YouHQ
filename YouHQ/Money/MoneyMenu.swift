//
//  MoneyMenu.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct MoneyMenu: View {
	let vm: MoneyScreen.ViewModel

	var body: some View {
		Button {
			vm.showAddBankAccountSheet()
		} label: {
			Label("Add Bank Account", systemImage: "building.columns.fill")
		}

		Button {
			vm.showAddInvestmentAccountSheet()
		} label: {
			Label("Add Investment Account", systemImage: "chart.line.uptrend.xyaxis")
		}

		Button {
			vm.showAddHealthSavingsAccountSheet()
		} label: {
			Label("Add HSA/FSA", systemImage: "cross.case.fill")
		}

		Button {
			vm.showAddInsurancePolicySheet()
		} label: {
			Label("Add Insurance Policy", systemImage: "shield.fill")
		}

		Button {
			vm.showAddOtherSheet()
		} label: {
			Label("Add Other", systemImage: "ellipsis.circle.fill")
		}
	}
}
