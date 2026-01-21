//
//  MaintenanceItemEdit.swift
//  YouHQ
//
//  Created by Ryan Token on 1/14/26.
//

import SwiftUI

struct MaintenanceItemEdit: View {
	let coordinator: SectionEditSheet.ViewModel
	var focusedField: FocusState<Bool>.Binding

	var body: some View {
		if let maintenanceVM = coordinator.maintenanceViewModel {
			@Bindable var vm = maintenanceVM
			Section("Maintenance Info") {
				LabeledField(label: "Name") {
					TextField("", text: $vm.name)
						.focused(focusedField)
						.multilineTextAlignment(.trailing)
				}
				#if !os(macOS)
					.textInputAutocapitalization(.words)
				#endif

				LabeledField(label: "Description") {
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

			Section {
				LabeledField(label: "Every") {
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

				LabeledField(label: "Unit") {
					Picker(selection: $vm.intervalType) {
						ForEach(MaintenanceIntervalType.allCases, id: \.self) { type in
							Text(
								vm.intervalValue == 1
									? type.rawValue : "\(type.rawValue)s"
							).tag(type)
						}
					} label: {
						EmptyView()
					}
				}

				LabeledField(label: "Next Due Date") {
					DatePicker(
						"",
						selection: Binding(
							get: {
								if vm.isUsingManualDueDate {
									return vm.nextDueDate
										?? vm.calculatedNextDueDate
								} else {
									return vm.calculatedNextDueDate
								}
							},
							set: {
								vm.nextDueDate = $0
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

				LabeledField(label: "Notify When Due") {
					Toggle("", isOn: $vm.shouldNotify)
						.labelsHidden()
						.onChange(of: vm.shouldNotify) {
							vm.handleNotifyToggle()
						}
				}
			} header: {
				Text("Maintenance Interval")
			} footer: {
				if !vm.isUsingManualDueDate {
					Text(
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
				Text(
					"To receive maintenance reminders, please enable notifications in System Settings."
				)
			}

			Section("Website") {
				URLTextField(text: $vm.url)
			}

			PhotoPickerSection(
				title: "Image",
				viewModel: vm.photoPicker
			)

			Section("Notes") {
				TextEditor(text: $vm.notes)
					.frame(minHeight: 100)
					.scrollContentBackground(.hidden)
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
		draftOther: .constant(nil)
	)
}

#Preview("Vehicle Maintenance Item") {
	SectionEditSheet(
		section: .maintenanceItem(MaintenanceItem.vehicleSampleData),
		draftUtility: .constant(nil),
		draftInsurancePolicy: .constant(nil),
		draftMaintenanceItem: .constant(nil),
		draftOther: .constant(nil)
	)
}
