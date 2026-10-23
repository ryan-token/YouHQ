//
//  SalaryChart+SelectionInput.swift
//  YouHQ
//
//  Created by Ryan Token on 10/22/26.
//

import Charts
import SwiftUI

extension SalaryChart {
	/// Binds the chart's raw x selection. Owning the read here keeps each new touch position
	/// from re-evaluating the chart host; the view model resolves it into `selectedJob`.
	struct SelectionInput: ViewModifier {
		let vm: ViewModel

		func body(content: Content) -> some View {
			@Bindable var vm = vm
			content.chartXSelection(value: $vm.selectedJobLabel)
		}
	}
}
