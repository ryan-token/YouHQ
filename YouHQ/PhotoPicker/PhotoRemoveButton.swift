//
//  PhotoRemoveButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import SwiftUI

struct PhotoRemoveButton: View {
	let viewModel: PhotoPickerViewModel

	var body: some View {
		if viewModel.photoData != nil {
			Button("Remove Image", role: .destructive, action: removePhoto)
		}
	}

	private func removePhoto() {
		withAnimation {
			viewModel.clearPhoto()
		}
	}
}
