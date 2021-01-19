//
//  UIImage+CloudProviderType.swift
//  Cryptomator
//
//  Created by Philipp Schmid on 07.01.21.
//  Copyright © 2021 Skymatic GmbH. All rights reserved.
//

import CloudAccessPrivateCore
import UIKit

enum State {
	case normal
	case highlighted
}

extension UIImage {
	convenience init?(vaultIconFor cloudProviderType: CloudProviderType, state: State) {
		var assetName: String
		switch cloudProviderType {
		case .dropbox:
			assetName = "dropbox-vault"
		case .googleDrive:
			assetName = "google-drive-vault"
		case .localFileSystem:
			assetName = "file-provider-vault"
		case .webDAV:
			assetName = "webdav-vault"
		}
		if state == .highlighted {
			assetName += "-selected"
		}
		self.init(named: assetName)
	}

	convenience init?(storageIconFor cloudProviderType: CloudProviderType) {
		var assetName: String
		switch cloudProviderType {
		case .dropbox:
			assetName = "dropbox"
		case .googleDrive:
			assetName = "google-drive"
		case .localFileSystem:
			assetName = "file-provider"
		case .webDAV:
			assetName = "webdav"
		}
		self.init(named: assetName)
	}
}
