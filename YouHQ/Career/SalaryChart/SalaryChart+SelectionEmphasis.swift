//
//  SalaryChart+SelectionEmphasis.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import Charts
import SwiftUI

extension SalaryChart {
	/// Colors each bar with its job's color, dimming the others while one is selected.
	///
	/// Reading the resolved selection in the style-scale mapping, rather than in the marks,
	/// lets the chart reuse its content when the selection changes.
	struct SelectionEmphasis: ViewModifier {
		let vm: ViewModel
		let chartData: [JobChartData]

		func body(content: Content) -> some View {
			let selectedLabel = vm.selectedJob.map(vm.chartLabel(for:))
			let colors = Dictionary(
				chartData.map { (vm.chartLabel(for: $0), Color(databaseValue: $0.backgroundColor)) },
				uniquingKeysWith: { first, _ in first }
			)

			content.chartForegroundStyleScale { (label: String) in
				let color = colors[label] ?? .accentColor
				return selectedLabel == nil || selectedLabel == label ? color : color.opacity(0.5)
			}
		}
	}
}
