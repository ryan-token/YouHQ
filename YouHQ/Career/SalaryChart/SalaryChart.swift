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

				Chart(chartData) { data in
					BarMark(
						x: .value("Job", vm.chartLabel(for: data)),
						y: .value("Salary", data.salary)
					)
					.foregroundStyle(Color(databaseValue: data.backgroundColor))
					.opacity(vm.selectedJob == nil || vm.selectedJob?.id == data.id ? 1.0 : 0.5)
					.cornerRadius(6)
				}
				.frame(height: 200)
				.chartScrollableAxes(.horizontal)
				.chartXVisibleDomain(length: visibleBars())
				.chartXSelection(value: $vm.selectedJobLabel)
				.chartYAxis {
					AxisMarks(position: .leading) { value in
						AxisValueLabel {
							if let salary = value.as(Double.self) {
								HQText(vm.formatCompactSalary(salary))
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
					if let selectedJob = vm.selectedJob {
						VStack(spacing: 4) {
							Text(selectedJob.xLabel)
								.font(.caption)
								.bold()
							Text(selectedJob.salary, format: .currency(code: "USD"))
								.font(.caption)
								.blur(radius: hideSalaries ? 4 : 0)
						}
						.padding(.horizontal, 12)
						.padding(.vertical, 8)
						.background(
							Color(databaseValue: selectedJob.backgroundColor)
								.opacity(0.9)
						)
						.foregroundStyle(.white)
						.clipShape(.rect(cornerRadius: 8))
						.shadow(radius: 4)
						.padding(.top, 8)
						.transition(.opacity.combined(with: .scale(scale: 0.9)))
					}
				}
				#if os(macOS)
					.background(
						Color(.secondarySystemFill)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color.primary.opacity(0.1), lineWidth: 1)
							)
					)
				#else
					.background(
						Color(.secondarySystemGroupedBackground)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color.primary.opacity(0.1), lineWidth: 1)
							)
					)
				#endif

				.clipShape(.rect(cornerRadius: 12))
				.shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
			}
		}
	}

	private func visibleBars() -> Int {
		#if os(macOS)
			6
		#else
			UIDevice.current.userInterfaceIdiom == .pad ? 6 : 4
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
			startDate: Date(),
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
			startDate: Date(),
			endDate: Date(),
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
			startDate: Date(),
			endDate: Date(),
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
