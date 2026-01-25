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
				HStack {
					Image(systemName: "plus.circle.fill")
						.font(.title2)
					Text("Add More")
						.font(.headline)
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.ultraThinMaterial)
				.clipShape(.rect(cornerRadius: 12))
			}
			.buttonStyle(.plain)
			.padding(.bottom)
		}
	}
}

#Preview {
	MediaInfo.AddMoreButton(vm: MediaScreen.ViewModel())
}
