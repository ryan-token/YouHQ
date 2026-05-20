//
//  PhotoRemoveButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoRemoveButton: View {
	@Bindable var viewModel: PhotoPickerViewModel

	var body: some View {
		if viewModel.photoData != nil {
			Button("Remove Image", role: .destructive) {
				withAnimation {
					viewModel.clearPhoto()
				}
			}
		}
	}
}
