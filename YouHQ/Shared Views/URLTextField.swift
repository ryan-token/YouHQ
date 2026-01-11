//
//  URLTextField.swift
//  YouHQ
//
//  Created by Ryan Token on 1/10/26.
//

import SwiftUI

struct URLTextField: View {
	@Binding var text: String

	var body: some View {
		TextField("URL", text: $text)
			.textContentType(.URL)
			#if !os(macOS)
				.keyboardType(.URL)
				.textInputAutocapitalization(.never)
			#endif
			.autocorrectionDisabled()
	}
}

#Preview {
	@Previewable @State var url = "example.com"
	Form {
		URLTextField(text: $url)
	}
}
