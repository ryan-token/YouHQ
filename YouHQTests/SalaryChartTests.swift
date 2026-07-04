//
//  SalaryChartTests.swift
//  YouHQTests
//
//  Created by Ryan Token on 2/21/26.
//

import Dependencies
import DependenciesTestSupport
import Foundation
import Testing

@testable import YouHQ

extension YouHQTests {
	@Suite("Salary chart")
	struct SalaryChartViewModelTests {

		// MARK: - prepareChartData

		@Test("prepareChartData filters jobs without salary")
		func filtersJobsWithoutSalary() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Has Salary",
					salary: 100_000,
					backgroundColor: "blue"
				),
				Job(
					id: UUID(-2),
					profileID: UUID(-1),
					company: "No Salary",
					backgroundColor: "green"
				)
			]

			let chartData = vm.prepareChartData(from: jobs)
			#expect(chartData.count == 1)
			#expect(chartData[0].xLabel == "Has Salary")
		}

		@Test("prepareChartData sorts by start date ascending")
		func sortsByStartDate() {
			let vm = SalaryChart.ViewModel()
			let earlier = Date(timeIntervalSince1970: 500_000)
			let later = Date(timeIntervalSince1970: 900_000)
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Later Start",
					startDate: later,
					salary: 80_000,
					backgroundColor: "blue"
				),
				Job(
					id: UUID(-2),
					profileID: UUID(-1),
					company: "Earlier Start",
					startDate: earlier,
					salary: 60_000,
					backgroundColor: "green"
				)
			]

			let chartData = vm.prepareChartData(from: jobs)
			#expect(chartData[0].xLabel == "Earlier Start")
			#expect(chartData[1].xLabel == "Later Start")
		}

		@Test("prepareChartData falls back to end date when no start dates")
		func sortsByEndDateFallback() {
			let vm = SalaryChart.ViewModel()
			let earlier = Date(timeIntervalSince1970: 500_000)
			let later = Date(timeIntervalSince1970: 900_000)
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Later End",
					endDate: later,
					salary: 80_000,
					backgroundColor: "blue"
				),
				Job(
					id: UUID(-2),
					profileID: UUID(-1),
					company: "Earlier End",
					endDate: earlier,
					salary: 60_000,
					backgroundColor: "green"
				)
			]

			let chartData = vm.prepareChartData(from: jobs)
			#expect(chartData[0].xLabel == "Earlier End")
			#expect(chartData[1].xLabel == "Later End")
		}

		@Test("prepareChartData uses 'Untitled' for empty company")
		func untitledForEmptyCompany() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "",
					salary: 50_000,
					backgroundColor: "blue"
				)
			]

			let chartData = vm.prepareChartData(from: jobs)
			#expect(chartData[0].xLabel == "Untitled")
		}

		@Test("prepareChartData assigns correct indexes")
		func assignsIndexes() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "A",
					startDate: Date(timeIntervalSince1970: 100),
					salary: 50_000,
					backgroundColor: "blue"
				),
				Job(
					id: UUID(-2),
					profileID: UUID(-1),
					company: "B",
					startDate: Date(timeIntervalSince1970: 200),
					salary: 70_000,
					backgroundColor: "green"
				),
				Job(
					id: UUID(-3),
					profileID: UUID(-1),
					company: "C",
					startDate: Date(timeIntervalSince1970: 300),
					salary: 90_000,
					backgroundColor: "red"
				)
			]

			let chartData = vm.prepareChartData(from: jobs)
			#expect(chartData[0].index == 0)
			#expect(chartData[1].index == 1)
			#expect(chartData[2].index == 2)
		}

		// MARK: - formatCompactSalary

		@Test(
			"formatCompactSalary formats values correctly",
			arguments: [
				(1_500_000.0, "$1.5M"),
				(1_000_000.0, "$1.0M"),
				(150_000.0, "$150K"),
				(1_000.0, "$1K"),
				(75_000.0, "$75K"),
				(500.0, "$500"),
				(0.0, "$0"),
				(50.0, "$50")
			] as [(Double, String)]
		)
		func formatCompactSalary(value: Double, expected: String) {
			let vm = SalaryChart.ViewModel()
			#expect(vm.formatCompactSalary(value, currencyCode: "USD") == expected)
		}

		@Test(
			"formatCompactSalary uses the currency's symbol and compact suffix",
			arguments: [
				("USD", "$"),
				("EUR", "€"),
				("GBP", "£"),
				("JPY", "¥")
			] as [(String, String)]
		)
		func compactSalaryUsesCurrencySymbol(code: String, symbol: String) {
			let vm = SalaryChart.ViewModel()

			let thousands = vm.formatCompactSalary(150_000, currencyCode: code)
			#expect(thousands.contains(symbol))
			#expect(thousands.hasSuffix("K"))

			let millions = vm.formatCompactSalary(2_000_000, currencyCode: code)
			#expect(millions.contains(symbol))
			#expect(millions.hasSuffix("M"))
		}

		// MARK: - formatXAxisLabel

		@Test("formatXAxisLabel strips trailing index number")
		func stripsIndex() {
			let vm = SalaryChart.ViewModel()
			#expect(vm.formatXAxisLabel("Apple (1)") == "Apple")
			#expect(vm.formatXAxisLabel("Google (12)") == "Google")
		}

		@Test("formatXAxisLabel preserves label without index")
		func preservesLabelWithoutIndex() {
			let vm = SalaryChart.ViewModel()
			#expect(vm.formatXAxisLabel("Apple") == "Apple")
		}

		// MARK: - chartLabel

		@Test("chartLabel appends 1-based index")
		func chartLabelFormat() {
			let vm = SalaryChart.ViewModel()
			let data = SalaryChart.JobChartData(
				id: UUID(-1),
				xLabel: "Apple",
				salary: 150_000,
				backgroundColor: "blue",
				index: 0
			)
			#expect(vm.chartLabel(for: data) == "Apple (1)")
		}

		// MARK: - selectedJob via label

		@Test("setting selectedJobLabel updates selectedJob from cached data")
		func selectedJobFromLabel() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Apple",
					startDate: Date(timeIntervalSince1970: 100),
					salary: 150_000,
					backgroundColor: "blue"
				),
				Job(
					id: UUID(-2),
					profileID: UUID(-1),
					company: "Google",
					startDate: Date(timeIntervalSince1970: 200),
					salary: 180_000,
					backgroundColor: "green"
				)
			]

			_ = vm.prepareChartData(from: jobs)

			vm.selectedJobLabel = "Google (2)"
			#expect(vm.selectedJob?.xLabel == "Google")
			#expect(vm.selectedJob?.salary == 180_000)
		}

		@Test("setting selectedJobLabel to nil clears selectedJob")
		func clearSelectedJob() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Apple",
					salary: 150_000,
					backgroundColor: "blue"
				)
			]

			_ = vm.prepareChartData(from: jobs)
			vm.selectedJobLabel = "Apple (1)"
			#expect(vm.selectedJob != nil)

			vm.selectedJobLabel = nil
			#expect(vm.selectedJob == nil)
		}

		@Test("setting selectedJobLabel to non-matching value clears selectedJob")
		func nonMatchingLabel() {
			let vm = SalaryChart.ViewModel()
			let jobs = [
				Job(
					id: UUID(-1),
					profileID: UUID(-1),
					company: "Apple",
					salary: 150_000,
					backgroundColor: "blue"
				)
			]

			_ = vm.prepareChartData(from: jobs)
			vm.selectedJobLabel = "Nonexistent (99)"
			#expect(vm.selectedJob == nil)
		}
	}

	@Suite("Double+Currency")
	struct DoubleCurrencyTests {

		// Exact strings assume the test host's en_US locale, matching the rest of
		// this suite. The multi-currency tests below assert locale-robust behavior.
		@Test(
			"formatted(currencyCode:) formats USD amounts",
			arguments: [
				(0.0, "$0.00"),
				(9.99, "$9.99"),
				(1234.56, "$1,234.56"),
				(1_000_000.0, "$1,000,000.00"),
				(0.5, "$0.50")
			] as [(Double, String)]
		)
		func formatsUSD(value: Double, expected: String) {
			#expect(value.formatted(currencyCode: "USD") == expected)
		}

		@Test("formatted(currencyCode:) formats negative values")
		func formatsNegative() {
			let result = (-25.99).formatted(currencyCode: "USD")
			// The currency format style uses a locale-dependent negative format.
			#expect(result.contains("25.99"))
		}

		@Test(
			"formatted(currencyCode:) uses each currency's symbol",
			arguments: [
				("USD", "$"),
				("EUR", "€"),
				("GBP", "£"),
				("JPY", "¥")
			] as [(String, String)]
		)
		func usesCurrencySymbol(code: String, symbol: String) {
			#expect((42.0).formatted(currencyCode: code).contains(symbol))
		}

		@Test("formatted(currencyCode:) respects currency-specific fraction digits")
		func honorsFractionDigits() {
			// JPY has no minor unit, so a fractional amount is rounded to a whole
			// yen; USD keeps two fraction digits.
			let yen = (1234.56).formatted(currencyCode: "JPY")
			#expect(!yen.contains("56"))

			let dollars = (1234.56).formatted(currencyCode: "USD")
			#expect(dollars.contains("56"))
		}
	}
}
