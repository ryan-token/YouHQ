//
//  JobSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

struct JobSection: View {
	let job: Job
	let hideSalaries: Bool
	let onColorChange: (Color) -> Void
	let onTap: (() -> Void)?

	var body: some View {
		InfoSection(
			job.company.isNotEmpty ? job.company : "Job",
			backgroundColor: Color(databaseValue: job.backgroundColor),
			onColorChange: onColorChange,
			onTap: onTap
		) {
			if job.company.isNotEmpty {
				Text(job.company)
					.sectionTitle()
			}

			if job.title.isNotEmpty {
				InfoRow("Title:", value: job.title)
			}

			if job.isCurrent {
				InfoRow("Status:", value: "Current")
			}

			InfoRow("Employment type:", value: job.employmentType.rawValue)

			if let startDate = job.startDate {
				InfoRow(
					"Start date:",
					value: startDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			if let endDate = job.endDate {
				InfoRow(
					"End date:",
					value: endDate.formatted(
						date: .abbreviated,
						time: .omitted
					)
				)
			}

			if let salary = job.salary {
				InfoRow(
					"Salary:",
					value: salary.asCost,
					blurred: hideSalaries
				)
			}

			if job.url.isNotEmpty {
				LinkRow("Website:", url: job.url)
			}

			if job.notes.isNotEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text("Notes:")
						.font(.headline)
						.foregroundStyle(.white)
					Text(job.notes)
						.foregroundStyle(.white)
				}
			}
		}
	}
}
