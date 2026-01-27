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

		var body: some View {
			Menu {
				MediaMenu(vm: vm)
			} label: {
				AddMoreButtonLabel(text: "Add More")
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	MediaInfo.AddMoreButton(vm: MediaScreen.ViewModel())
}
