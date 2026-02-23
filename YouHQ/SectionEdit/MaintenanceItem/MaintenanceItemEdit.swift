//
//  MaintenanceItemEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct MaintenanceItemEdit: View {
	enum Field: Hashable {
		case name, url, notes
	}

	let coordinator: SectionEditSheet.ViewModel
	let autoFocus: Bool
	@FocusState private var focusedField: Field?
	@State private var hasAppeared = false

	var body: some View {
		if let maintenanceVM = coordinator.maintenanceViewModel {
			@Bindable var vm = maintenanceVM
			Section("Maintenance Info") {
				LabeledField("Name") {
					TextField("", text: $vm.name)
						.focused($focusedField, equals: .name)
						.onSubmit { focusedField = .url }
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField("Description") {
					TextField(
						"",
						text: $vm.itemDescription,
						axis: .vertical
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.sentences)
				#endif
				.lineLimit(3...6)
			}
			.onAppear {
				if autoFocus, !hasAppeared {
					hasAppeared = true
					focusedField = .name
				}
			}

			Section {
				LabeledField("Every") {
					TextField(
						"",
						value: $vm.intervalValue,
						format: .number
					)
					.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.keyboardType(.numberPad)
				#endif

				LabeledField("Unit", shouldOverrideTap: false) {
					Picker(selection: $vm.intervalType) {
						ForEach(MaintenanceIntervalType.allCases, id: \.self) { type in
							HQText(
								vm.intervalValue == 1
									? type.rawValue : "\(type.rawValue)s"
							).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField("Next Due Date") {
					DatePicker(
						"",
						selection: Binding(
							get: {
								if vm.isUsingManualDueDate {
									return vm.dueDate
										?? vm.calculatedNextDueDate
								} else {
									return vm.calculatedNextDueDate
								}
							},
							set: {
								vm.dueDate = $0
								vm.isUsingManualDueDate = true
							}
						),
						displayedComponents: .date
					)
					.labelsHidden()
				}

				if vm.isUsingManualDueDate {
					Button("Reset Due Date") {
						vm.resetToAutomaticDueDate()
					}
					.buttonStyle(.bordered)
				}

				LabeledField("Notify When Due") {
					Toggle("", isOn: $vm.shouldNotify)
						.labelsHidden()
						.onChange(of: vm.shouldNotify) {
							vm.handleNotifyToggle()
						}
				}
			} header: {
				HQText("Maintenance Interval")
			} footer: {
				if !vm.isUsingManualDueDate {
					HQText(
						"Automatically set to \(vm.calculatedNextDueDate.formatted(date: .abbreviated, time: .omitted)) based on your interval"
					)
				}
			}
			.alert(
				"Notifications Disabled",
				isPresented: $vm.isShowingPermissionAlert
			) {
				Button("Open Settings") {
					vm.openNotificationSettings()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				HQText(
					"To receive maintenance reminders, please enable notifications in Settings."
				)
			}

			Section("Website") {
				URLTextField(text: $vm.url)
					.focused($focusedField, equals: .url)
					.onSubmit { focusedField = .notes }
			}

			PhotoPickerSection(
				title: "Image",
				viewModel: vm.photoPicker
			)

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
					.focused($focusedField, equals: .notes)
					.onSubmit { focusedField = nil }
			}
		}
	}
}

#Preview("Residence Maintenance Item") {
	SectionEditSheet(
		section: .maintenanceItem(MaintenanceItem.residenceSampleData),
		draftUtility: .constant(nil),
		draftInsurancePolicy: .constant(nil),
		draftMaintenanceItem: .constant(nil),
		draftPaintColor: .constant(nil),
		draftOther: .constant(nil),
		draftJob: .constant(nil),
		draftDevice: .constant(nil),
		draftServiceProvider: .constant(nil),
		draftSubscription: .constant(nil),
		draftBankAccount: .constant(nil),
		draftInvestmentAccount: .constant(nil),
		draftHealthSavingsAccount: .constant(nil)
	)
}

#Preview("Vehicle Maintenance Item") {
	SectionEditSheet(
		section: .maintenanceItem(MaintenanceItem.vehicleSampleData),
		draftUtility: .constant(nil),
		draftInsurancePolicy: .constant(nil),
		draftMaintenanceItem: .constant(nil),
		draftPaintColor: .constant(nil),
		draftOther: .constant(nil),
		draftJob: .constant(nil),
		draftDevice: .constant(nil),
		draftServiceProvider: .constant(nil),
		draftSubscription: .constant(nil),
		draftBankAccount: .constant(nil),
		draftInvestmentAccount: .constant(nil),
		draftHealthSavingsAccount: .constant(nil)
	)
}
