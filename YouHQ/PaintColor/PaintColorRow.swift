//
//  PaintColorRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SwiftUI

struct PaintColorRow: View {
	let paintColor: PaintColor
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .center, spacing: 12) {
				// Color swatch
				RoundedRectangle(cornerRadius: 8)
					.fill(Color(databaseValue: paintColor.backgroundColor))
					.stroke(.separator, lineWidth: 1)
					.frame(width: 40, height: 40)

				VStack(alignment: .leading, spacing: 4) {
					HQText(paintColor.room.isNotEmpty ? paintColor.room : "No Room")
						.font(.headline)

					if paintColor.colorName.isNotEmpty {
						HQText(paintColor.colorName)
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}

					HStack(spacing: 4) {
						if paintColor.manufacturer.isNotEmpty {
							HQText(paintColor.manufacturer)
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						if paintColor.manufacturer.isNotEmpty
							&& paintColor.surfaceType.isNotEmpty
						{
							HQText("•")
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						if paintColor.surfaceType.isNotEmpty {
							HQText(paintColor.surfaceType)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
				}

				Spacer()

				// URL link
				if paintColor.url.isNotEmpty {
					LinkRow(url: paintColor.url, showOnPlainBackground: true)
				}
			}
			.padding(.vertical, 4)
		}
		.contentShape(.rect)
		.foregroundStyle(.primary)
		#if os(macOS)
			.listRowSeparator(.hidden)
		#endif
	}
}

#Preview {
	PaintColorRow(paintColor: .sampleData, onTap: {})
}
