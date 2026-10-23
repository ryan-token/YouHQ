//
//  SalaryChart.swift
//  YouHQ
//
//  Created by Ryan Token on 2/1/26.
//

import Charts
import SwiftUI

struct SalaryChart: View {
	@State private var vm = ViewModel()
	@Environment(\.defaultCurrencyCode) private var defaultCurrencyCode
	#if !os(macOS)
		@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	#endif

	let jobs: [Job]
	let hideSalaries: Bool

	var body: some View {
		let chartData = vm.prepareChartData(from: jobs)

		if chartData.count < 2 {
			EmptyView()
		} else {
			VStack(alignment: .leading, spacing: 12) {
				HQText("Salary History", italic: true)
					.font(.title3)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)

				// Selection is read only inside the focused modifiers and overlay below, so dragging
				// across bars doesn't rebuild the marks.
				Chart(chartData) { data in
					let label = vm.chartLabel(for: data)
					BarMark(
						x: .value("Job", label),
						y: .value("Salary", data.salary)
					)
					.foregroundStyle(by: .value("Job", label))
					.cornerRadius(6)
				}
				.chartLegend(.hidden)
				.modifier(SelectionEmphasis(vm: vm, chartData: chartData))
				.frame(height: 200)
				.chartScrollableAxes(.horizontal)
				.chartXVisibleDomain(length: visibleBars())
				.modifier(SelectionInput(vm: vm))
				.chartYAxis {
					AxisMarks(position: .leading) { value in
						AxisValueLabel {
							if let salary = value.as(Double.self) {
								HQText(vm.formatCompactSalary(salary, currencyCode: defaultCurrencyCode))
									.font(.caption)
									.blur(radius: hideSalaries ? 4 : 0)
							}
						}
						AxisGridLine()
					}
				}
				.chartXAxis {
					AxisMarks { value in
						AxisValueLabel {
							if let label = value.as(String.self) {
								Text(vm.formatXAxisLabel(label))
									.font(.caption)
									.lineLimit(1)
							}
						}
					}
				}
				.padding()
				.overlay(alignment: .top) {
					SelectionTooltipOverlay(vm: vm, hideSalaries: hideSalaries)
				}
				.background {
					#if os(macOS)
						RoundedRectangle(cornerRadius: 12)
							.fill(.fill.tertiary)
							.stroke(.primary.opacity(0.2), lineWidth: 1)
					#else
						RoundedRectangle(cornerRadius: 12)
							.fill(.background.secondary)
							.stroke(.primary.opacity(0.1), lineWidth: 1)
					#endif
				}

				.clipShape(.rect(cornerRadius: 12))
				.shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
			}
		}
	}

	/// How many bars fit before the chart scrolls: more when the window is wide.
	private func visibleBars() -> Int {
		#if os(macOS)
			6
		#else
			horizontalSizeClass == .regular ? 6 : 4
		#endif
	}
}

#Preview {
	let sampleJobs = [
		Job(
			id: UUID(),
			profileID: UUID(),
			company: "Apple",
			title: "Software Engineer",
			startDate: Date.now,
			endDate: nil,
			isCurrent: true,
			salary: 150000,
			employmentType: .fullTime,
			backgroundColor: "blue",
			url: "",
			notes: ""
		),
		Job(
			id: UUID(),
			profileID: UUID(),
			company: "Google",
			title: "Senior Engineer",
			startDate: Date.now,
			endDate: Date.now,
			isCurrent: false,
			salary: 180000,
			employmentType: .fullTime,
			backgroundColor: "green",
			url: "",
			notes: ""
		),
		Job(
			id: UUID(),
			profileID: UUID(),
			company: "Microsoft",
			title: "Engineer",
			startDate: Date.now,
			endDate: Date.now,
			isCurrent: false,
			salary: 120000,
			employmentType: .fullTime,
			backgroundColor: "purple",
			url: "",
			notes: ""
		)
	]

	VStack(spacing: 20) {
		SalaryChart(jobs: sampleJobs, hideSalaries: false)
			.padding()

		SalaryChart(jobs: sampleJobs, hideSalaries: true)
			.padding()
	}
}
