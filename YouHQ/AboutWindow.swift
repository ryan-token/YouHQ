//
//  AboutWindow.swift
//  YouHQ
//
//  Created by Ryan Token on 2/7/26.
//

import SwiftUI

struct AboutWindow: View {
	private var appVersionAndBuild: String {
		let version = Bundle.main
			.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
		let build = Bundle.main
			.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
		return "Version \(version) (\(build))"
	}

	private var copyright: String {
		let calendar = Calendar.current
		let year = calendar.component(.year, from: Date())
		return "© \(year) Ryan Token"
	}

	private var developerWebsite: URL {
		URL(string: "https://ryantoken.com/")!
	}

    var body: some View {
		VStack(spacing: 14) {
			Image("AppIcon")
				.resizable()
				.scaledToFit()
				.frame(width: 80)
			HQText("YouHQ")
				.font(.title)
			VStack(spacing: 6) {
				HQText(appVersionAndBuild)
				HQText(copyright)
			}
			.font(.callout)
			Link(
				"Developer Website",
				destination: developerWebsite
			)
			.foregroundStyle(.accent)
		}
		.padding()
		.frame(minWidth: 400, minHeight: 260)
    }
}

#Preview {
    AboutWindow()
}
