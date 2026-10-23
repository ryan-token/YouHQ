//
//  CareerScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct CareerScreen: View {
	@Namespace private var addButtonNamespace
	@State private var vm = ViewModel()
	@AppStorage("hideSalaries") private var hideSalaries = false

	var body: some View {
		// Sorted once per update rather than once per read.
		let sortedJobs = vm.sortedJobs

		List {
			Group {
				SharingStatus(for: vm.selectedProfile)

				Group {
					if sortedJobs.isEmpty && vm.otherViewModel.others.isEmpty {
						NoJobsView(vm: vm)
					} else {
						HideSalariesToggle(hideSalaries: $hideSalaries)

						SalaryChart(jobs: sortedJobs, hideSalaries: hideSalaries)

						ForEach(sortedJobs) { job in
							JobSection(
								job: job,
								hideSalaries: hideSalaries,
								onColorChange: { newColor in
									vm.jobViewModel.updateBackgroundColor(
										newColor,
										for: job
									)
								},
								onTap: { vm.showEditSheet(for: .job(job), sourceID: job.id.uuidString) }
							)
							.matchedTransitionSource(id: job.id.uuidString, in: addButtonNamespace)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button("Delete", systemImage: "trash", role: .destructive) {
									vm.jobViewModel.delete(job)
								}
							}
						}

						ForEach(vm.otherViewModel.others) { other in
							OtherSection(
								other: other,
								hideCosts: hideSalaries,
								onColorChange: { newColor in
									vm.otherViewModel.updateBackgroundColor(
										newColor,
										for: other
									)
								},
								onTap: { vm.showEditSheet(for: .other(other), sourceID: other.id.uuidString) }
							)
							.matchedTransitionSource(id: other.id.uuidString, in: addButtonNamespace)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button("Delete", systemImage: "trash", role: .destructive) {
									vm.otherViewModel.delete(other)
								}
							}
						}

						AddMoreButton(vm: vm)
					}
				}
				.opacity(vm.hasCompletedInitialLoad ? 1 : 0)
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: sortedJobs)
		.animation(.default, value: vm.otherViewModel.others)
		.navigationTitle("Career")
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar { Toolbar(vm: vm, namespace: addButtonNamespace) }
		.environment(\.sheetNamespace, addButtonNamespace)
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadCareerData()
		}
		.reloadOnProfileChange(
			profileCount: vm.profiles.count,
			initialLoad: vm.loadCareerData
		)
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(section: sectionToEdit)
					#if !os(macOS)
						.navigationTransition(.zoom(sourceID: vm.sheetTransitionSourceID, in: addButtonNamespace))
					#endif
			}
		}
		#if !os(visionOS)
			.scrollDismissesKeyboard(.immediately)
		#endif
	}
}

#Preview {
	let _ = prepareDependencies { // swiftlint:disable:this redundant_discardable_let
		try? $0.bootstrapDatabase()
		try? $0.defaultDatabase.seed()
	}

	NavigationStack {
		CareerScreen()
	}
}
