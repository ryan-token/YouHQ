//
//  AppEntryPoint.swift
//  YouHQ
//
//  Created by Ryan Token on 12/29/25.
//

import SwiftUI

struct AppEntryPoint: View {
	@AppStorage("hasLaunchedApp") private var hasLaunchedApp = false
	// One per window: `WindowGroup` creates a separate `AppEntryPoint` for each scene.
	@State private var paywallPresenter = PaywallPresenter()

	var body: some View {
		Group {
			if hasLaunchedApp {
				AppTabView()
			} else {
				AppOnboardingFlow()
			}
		}
		.environment(paywallPresenter)
		#if DEBUG
			.preferredColorScheme(ScreenshotMode.colorScheme)
		#endif
	}
}

#Preview {
	AppEntryPoint()
}
