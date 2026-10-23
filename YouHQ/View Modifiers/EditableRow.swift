//
//  EditableRow.swift
//  YouHQ
//
//  Created by Ryan Token on 10/23/26.
//

import SwiftUI

extension View {
	/// Makes a record's list row the zoom source for its edit sheet and adds swipe-to-delete.
	func editableRow(id: UUID, onDelete: @escaping () -> Void) -> some View {
		modifier(EditableRow(id: id, onDelete: onDelete))
	}
}

private struct EditableRow: ViewModifier {
	let id: UUID
	let onDelete: () -> Void
	@Environment(\.sheetNamespace) private var namespace

	func body(content: Content) -> some View {
		content
			.matchedTransitionSource(id: id.uuidString, in: namespace)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
			}
	}
}
