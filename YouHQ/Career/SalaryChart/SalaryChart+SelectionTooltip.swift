//
//  SalaryChart+SelectionTooltip.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import SwiftUI

extension SalaryChart {
	/// The callout shown above the chart for the bar being touched.
	struct SelectionTooltip: View {
		@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode

		let job: JobChartData
		let hideSalaries: Bool

		var body: some View {
			let backgroundColor = Color(databaseValue: job.backgroundColor)

			VStack(spacing: 4) {
				Text(job.xLabel)
					.font(.caption)
					.bold()
				Text(
					job.salary,
					format: .currency(code: Currency.resolved(job.currencyCode, default: defaultCurrencyCode))
				)
				.font(.caption)
				.blur(radius: hideSalaries ? 4 : 0)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 8)
			.legibleForeground(on: backgroundColor)
			.background(backgroundColor.opacity(0.9))
			.clipShape(.rect(cornerRadius: 8))
			.shadow(radius: 4)
		}
	}
}
