//
//  NamespaceEnvironment.swift
//  YouHQ
//
//  Created by Ryan Token on 2/17/26.
//

import SwiftUI

private struct SheetNamespaceKey: EnvironmentKey {
	static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
	var sheetNamespace: Namespace.ID? {
		get { self[SheetNamespaceKey.self] }
		set { self[SheetNamespaceKey.self] = newValue }
	}
}

extension View {
	/// Applies `matchedTransitionSource` only when a namespace is available.
	@ViewBuilder func matchedTransitionSource(id: String, in namespace: Namespace.ID?) -> some View {
		if let namespace {
			self.matchedTransitionSource(id: id, in: namespace)
		} else {
			self
		}
	}
}
