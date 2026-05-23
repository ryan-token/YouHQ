//
//  SalaryChartView+ViewModel.swift
//  YouHQ
//
//  Created by Ryan Token on 2/1/26.
//

import Charts
import SwiftUI

extension SalaryChart {
	@Observable
	class ViewModel {
		var selectedJob: JobChartData?
		var selectedJobLabel: String? {
			didSet {
				updateSelectedJobFromLabel()
			}
		}
		private var cachedChartData: [JobChartData] = []

		func prepareChartData(from jobs: [Job]) -> [JobChartData] {
			let filtered = jobs.filter { $0.salary != nil }
				.sorted { job1, job2 in
					if let start1 = job1.startDate, let start2 = job2.startDate {
						return start1 < start2
					} else if let end1 = job1.endDate, let end2 = job2.endDate {
						return end1 < end2
					} else if job1.startDate != nil {
						return true
					} else if job2.startDate != nil {
						return false
					} else {
						return true
					}
				}

			let chartData = filtered.enumerated().map { index, job in
				JobChartData(
					id: job.id,
					xLabel: job.company.isNotEmpty ? job.company : "Untitled",
					salary: job.salary ?? 0,
					backgroundColor: job.backgroundColor,
					index: index
				)
			}
			cachedChartData = chartData
			return chartData
		}

		func chartLabel(for data: JobChartData) -> String {
			"\(data.xLabel) (\(data.index + 1))"
		}

		func formatCompactSalary(_ value: Double) -> String {
			if value >= 1_000_000 {
				let millions = (value / 1_000_000).formatted(.number.precision(.fractionLength(1)))
				return "$\(millions)M"
			} else if value >= 1000 {
				let thousands = (value / 1000).formatted(.number.precision(.fractionLength(0)))
				return "$\(thousands)K"
			} else {
				return value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
			}
		}

		func formatXAxisLabel(_ label: String) -> String {
			label.replacing(/\s\(\d+\)$/, with: "")
		}

		private func updateSelectedJobFromLabel() {
			guard let label = selectedJobLabel else {
				selectedJob = nil
				return
			}
			selectedJob = cachedChartData.first { chartLabel(for: $0) == label }
		}
	}

	struct JobChartData: Identifiable, Equatable {
		let id: UUID
		let xLabel: String
		let salary: Double
		let backgroundColor: String
		let index: Int
	}
}
