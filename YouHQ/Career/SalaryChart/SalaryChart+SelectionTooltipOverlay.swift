//
//  SalaryChart+SelectionTooltipOverlay.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension SalaryChart {
	/// Shows the tooltip for the selected bar, reading the selection itself so the chart host
	/// doesn't depend on it.
	struct SelectionTooltipOverlay: View {
		let vm: ViewModel
		let hideSalaries: Bool

		var body: some View {
			if let selectedJob = vm.selectedJob {
				SelectionTooltip(job: selectedJob, hideSalaries: hideSalaries)
					.padding(.top, 8)
					.transition(.opacity.combined(with: .scale(scale: 0.9)))
			}
		}
	}
}
