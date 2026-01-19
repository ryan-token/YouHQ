//
//  SharingStatus.swift
//  YouHQ
//
//  Created by Ryan Token on 1/19/26.
//

import SwiftUI

struct SharingStatus: View {
	let vm: ResidenceScreen.ViewModel

    var body: some View {
		ForEach(vm.profiles, id: \.profile.id) { profile in
			if profile.profile.id == vm.selectedProfile?.profile.id {
				if profile.isShared {
					Button {
						Task {
							await vm.shareResidenceTapped()
						}
					} label: {
						HStack {
							Image(systemName: "network")
							Text("Shared")
						}
					}
					.buttonStyle(.plain)
					.padding(.vertical, 6)
					.padding(.horizontal, 12)
					.background(.blue)
					.foregroundStyle(.white)
					.clipShape(.capsule)
				}
			}
		}
    }
}

#Preview {
	SharingStatus(vm: ResidenceScreen.ViewModel())
}
