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
		List {
			Group {
				SharingStatus(for: vm.selectedProfile)

				if vm.sortedJobs.isEmpty && vm.otherViewModel.others.isEmpty {
					NoJobsView(vm: vm)
				} else {
					HideSalariesToggle(hideSalaries: $hideSalaries)

					SalaryChart(jobs: vm.sortedJobs, hideSalaries: hideSalaries)

					ForEach(vm.sortedJobs) { job in
						JobSection(
							job: job,
							hideSalaries: hideSalaries,
							onColorChange: { newColor in
								vm.jobViewModel.updateBackgroundColor(
									newColor,
									for: job
								)
							},
							onTap: {
								vm.sheetTransitionSourceID = job.id.uuidString
								vm.sectionToEdit = .job(job)
								vm.isShowingSectionEditSheet = true
							}
						)
						.matchedTransitionSource(id: job.id.uuidString, in: addButtonNamespace)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								vm.jobViewModel.delete(job)
							} label: {
								Label("Delete", systemImage: "trash")
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
							onTap: {
								vm.sheetTransitionSourceID = other.id.uuidString
								vm.sectionToEdit = .other(other)
								vm.isShowingSectionEditSheet = true
							}
						)
						.matchedTransitionSource(id: other.id.uuidString, in: addButtonNamespace)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								vm.otherViewModel.delete(other)
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					}

					AddMoreButton(vm: vm)
				}
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
		}
		.animation(.default, value: vm.sortedJobs)
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
		.onChange(of: vm.profiles.count) { oldCount, newCount in
			if oldCount == 0 && newCount > 0 { // so we load the default profile on initial sync
				Task { await vm.loadCareerData() }
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .profileDidChange)) { _ in
			Task { await vm.loadCareerData() }
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftOther: $vm.otherViewModel.draftOther,
					draftJob: $vm.jobViewModel.draftJob
				)
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
