//
//  PhotoViewerPayload.swift
//  YouHQ
//
//  Created by Ryan Token on 1/16/26.
//

import Foundation

struct PhotoViewerPayload: Identifiable {
	let id = UUID()
	let data: Data
}
