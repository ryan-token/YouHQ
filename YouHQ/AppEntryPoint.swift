//
//  AppEntryPoint.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SwiftUI

struct AppEntryPoint: View {
	@AppStorage("hasLaunchedApp") var hasLaunchedApp = false

	var body: some View {
		if hasLaunchedApp {
			AppTabView()
		} else {
			AppOnboardingFlow()
		}
	}
}

#Preview {
	AppEntryPoint()
}
