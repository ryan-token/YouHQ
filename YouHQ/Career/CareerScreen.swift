//
//  CareerScreen.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SQLiteData
import SwiftUI

struct CareerScreen: View {
	@State private var vm = ViewModel()
	@AppStorage("hideSalaries") private var hideSalaries = false

	var body: some View {
		List {
			Group {
				if vm.sortedJobs.isEmpty && vm.otherViewModel.others.isEmpty {
					NoJobsView(vm: vm)
				} else {
					HideSalariesToggle(hideSalaries: $hideSalaries)

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
								vm.sectionToEdit = .job(job)
								vm.isShowingSectionEditSheet = true
							}
						)
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
								vm.sectionToEdit = .other(other)
								vm.isShowingSectionEditSheet = true
							}
						)
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
		.toolbar { Toolbar(vm: vm) }
		.contentMargins(.top, 0)
		.scrollContentBackground(.hidden)
		.task {
			await vm.loadProfiles()
			await vm.loadCareerData()
		}
		.onChange(of: vm.profiles.count) {
			Task { await vm.loadCareerData() }
		}
		.sheet(isPresented: $vm.isShowingSectionEditSheet) {
			if let sectionToEdit = vm.sectionToEdit {
				SectionEditSheet(
					section: sectionToEdit,
					draftOther: $vm.otherViewModel.draftOther,
					draftJob: $vm.jobViewModel.draftJob
				)
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
