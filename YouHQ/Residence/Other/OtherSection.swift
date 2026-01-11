//
//  OtherSection.swift
//  YouHQ
//
//  Created by Ryan Token on 1/11/26.
//

import SwiftUI

struct OtherSection: View {
	@State private var vm: ViewModel
	let onTap: (() -> Void)?

	init(for other: Other, onTap: (() -> Void)? = nil) {
		_vm = State(wrappedValue: ViewModel(other: other))
		self.onTap = onTap
	}

	var body: some View {
		if let other = vm.other {
			InfoSection(
				other.name.isNotEmpty ? other.name : "Other",
				backgroundColor: $vm.backgroundColor,
				onColorChange: { newColor in
					vm.updateOtherBackgroundColor(newColor)
				},
				onTap: onTap
			) {
				if other.name.isNotEmpty {
					Text(other.name)
						.sectionTitle()
				}

				if other.otherDescription.isNotEmpty {
					InfoRow("Description:", value: other.otherDescription)
				}

				if other.url.isNotEmpty {
					LinkRow("Website:", url: other.url)
				}

				if other.notes.isNotEmpty {
					VStack(alignment: .leading, spacing: 4) {
						Text("Notes:")
							.font(.headline)
							.foregroundStyle(.white)
						Text(other.notes)
							.foregroundStyle(.white)
					}
				}
			}
		} else {
			Color.clear
				.task { await vm.loadOtherData() }
		}
	}
}

#Preview {
	OtherSection(for: Other.sampleData)
}
