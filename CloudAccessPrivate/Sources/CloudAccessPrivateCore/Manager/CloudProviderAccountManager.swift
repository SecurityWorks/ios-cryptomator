//
//  CloudProviderAccountManager.swift
//  CloudAccessPrivateCore
//
//  Created by Philipp Schmid on 20.10.20.
//  Copyright © 2020 Skymatic GmbH. All rights reserved.
//

import Foundation
import GRDB
public struct CloudProviderAccount: Decodable, FetchableRecord, TableRecord {
	public static let databaseTableName = "cloudProviderAccounts"
	static let accountUIDKey = "accountUID"
	static let cloudProviderTypeKey = "cloudProviderType"
	let accountUID: String
	let cloudProviderType: CloudProviderType
}

extension CloudProviderAccount: PersistableRecord {
	public func encode(to container: inout PersistenceContainer) {
		container[CloudProviderAccount.accountUIDKey] = accountUID
		container[CloudProviderAccount.cloudProviderTypeKey] = cloudProviderType
	}
}

extension CloudProviderType: DatabaseValueConvertible {}

public enum CloudProviderAccountError: Error {
	case accountNotFoundError
}

public class CloudProviderAccountManager {
	private let dbQueue: DatabaseQueue

	public init(dbQueue: DatabaseQueue) {
		self.dbQueue = dbQueue
	}

	public func getCloudProviderType(for accountUID: String) throws -> CloudProviderType {
		let cloudAccount = try dbQueue.read { db in
			return try CloudProviderAccount.fetchOne(db, key: accountUID)
		}
		guard let providerType = cloudAccount?.cloudProviderType else {
			throw CloudProviderAccountError.accountNotFoundError
		}
		return providerType
	}

	public func getAllAccountUIDs(for type: CloudProviderType) throws -> [String] {
		let accounts: [CloudProviderAccount] = try dbQueue.read { db in
			return try CloudProviderAccount
				.filter(Column("cloudProviderType") == type)
				.fetchAll(db)
		}
		return accounts.map { $0.accountUID }
	}

	public func saveNewAccount(_ account: CloudProviderAccount) throws {
		try dbQueue.write { db in
			try account.save(db)
		}
	}

	public func removeAccount(with accountUID: String) throws {
		try dbQueue.write { db in
			guard try CloudProviderAccount.deleteOne(db, key: accountUID) else {
				throw CloudProviderAccountError.accountNotFoundError
			}
		}
	}
}
