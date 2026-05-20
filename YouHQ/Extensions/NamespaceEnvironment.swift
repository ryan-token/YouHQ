//
//  NamespaceEnvironment.swift
//  YouHQ
//
//  Created by Ryan Token on 2/17/26.
//

import SwiftUI

extension EnvironmentValues {
	@Entry var sheetNamespace: Namespace.ID?
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
