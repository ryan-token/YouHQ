//
//  PhotoLibraryPickerButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import PhotosUI
import SwiftUI

/// Photos library picker. The label flips between "choose" and "change"
/// depending on whether a photo is already attached.
struct PhotoLibraryPickerButton: View {
	@Bindable var viewModel: PhotoPickerViewModel

	var body: some View {
		let labelText = viewModel.photoData != nil
			? "Choose Different Image"
			: "Choose from Library"
		PhotosPicker(
			selection: $viewModel.photoItem,
			matching: .not(.videos)
		) {
			Label(labelText, systemImage: "photo.on.rectangle")
		}
	}
}
