//
//  MediaScreen+AddMoreButton.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SwiftUI

extension MediaInfo {
	struct AddMoreButton: View {
		let vm: MediaScreen.ViewModel
		@Environment(\.sheetNamespace) private var namespace

		var body: some View {
			Menu {
				MediaMenu(vm: vm, sourceID: "addMoreButton")
			} label: {
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
			.matchedTransitionSource(id: "addMoreButton", in: namespace)
		}
	}
}

#Preview {
	MediaInfo.AddMoreButton(vm: MediaScreen.ViewModel())
}
