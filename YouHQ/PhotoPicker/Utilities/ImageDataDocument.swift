//
//  ImageDataDocument.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageDataDocument: FileDocument {
	static var readableContentTypes: [UTType] { [.image] }

	var data: Data

	init(data: Data) {
		self.data = data
	}

	init(configuration: ReadConfiguration) throws {
		data = configuration.file.regularFileContents ?? Data()
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		FileWrapper(regularFileWithContents: data)
	}
}
