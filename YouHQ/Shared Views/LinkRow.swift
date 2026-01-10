//
//  LinkRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct LinkRow: View {
	@Environment(\.openURL) private var openURL

	let label: String
	let url: String

	init(_ label: String, url: String) {
		self.label = label
		self.url = url
	}

	private var normalizedURL: URL? {
		var urlString = url.trimmingCharacters(in: .whitespaces)
		guard urlString.isNotEmpty else { return nil }

		// If URL doesn't have a scheme, add https://
		if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
			urlString = "https://" + urlString
		}

		return URL(string: urlString)
	}

	var body: some View {
		HStack(alignment: .center) {
			Text(label)
				.font(.headline)
			if let parsedURL = normalizedURL {
				Button {
					openURL(parsedURL)
				} label: {
					Text(url)
						.lineLimit(1)
						.truncationMode(.middle)
						.padding(.horizontal, 12)
						.padding(.vertical, 4)
						.background(.white.opacity(0.3))
						.clipShape(.rect(cornerRadius: 8))
				}
				.buttonStyle(.plain)
			} else {
				Text(url)
					.font(.body)
					.lineLimit(1)
					.truncationMode(.middle)
					.opacity(0.6)
			}
		}
		.foregroundStyle(.white)
	}
}

#Preview {
	VStack(spacing: 20) {
		LinkRow("Website:", url: "https://www.example.com")
			.padding()
			.background(.indigo)
			.clipShape(.rect(cornerRadius: 16))

		LinkRow("Website:", url: "test.com")
			.padding()
			.background(.teal)
			.clipShape(.rect(cornerRadius: 16))

		LinkRow("Website:", url: "https://www.verylongdomainname.com/path/to/resource")
			.padding()
			.background(.blue)
			.clipShape(.rect(cornerRadius: 16))
	}
	.padding()
}
