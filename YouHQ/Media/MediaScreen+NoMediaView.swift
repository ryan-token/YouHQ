//
//  MediaScreen+NoMediaView.swift
//  YouHQ
//
//  Created by Ryan Token on 1/24/26.
//

import SQLiteData
import SwiftUI

extension MediaScreen {
	struct NoMediaView: View {
		let vm: ViewModel

		var body: some View {
			ContentUnavailableView {
				Label("No media", systemImage: "desktopcomputer.and.macbook")
			} description: {
				Menu("Add Media") {
					MediaMenu(vm: vm)
				}
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
	}
}

#Preview {
	MediaScreen.NoMediaView(vm: MediaScreen.ViewModel())
}
