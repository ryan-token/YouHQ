//
//  PaintColorRow.swift
//  YouHQ
//
//  Created by Ryan Token on 1/20/26.
//

import SwiftUI

struct PaintColorRow: View {
	let paintColor: RoomPaintColor
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .center, spacing: 12) {
				// Color swatch
				RoundedRectangle(cornerRadius: 8)
					.fill(Color(databaseValue: paintColor.backgroundColor))
					.frame(width: 40, height: 40)
					.overlay {
						RoundedRectangle(cornerRadius: 8)
							.stroke(.separator, lineWidth: 1)
					}

				VStack(alignment: .leading, spacing: 4) {
					Text(paintColor.room.isNotEmpty ? paintColor.room : "No Room")
						.font(.headline)

					if paintColor.colorName.isNotEmpty {
						Text(paintColor.colorName)
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}

					HStack(spacing: 4) {
						if paintColor.manufacturer.isNotEmpty {
							Text(paintColor.manufacturer)
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						if paintColor.manufacturer.isNotEmpty
							&& paintColor.surfaceType.isNotEmpty
						{
							Text("•")
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						if paintColor.surfaceType.isNotEmpty {
							Text(paintColor.surfaceType)
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
