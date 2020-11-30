//
//  AppDelegate.swift
//  Cryptomator
//
//  Created by Philipp Schmid on 27.04.20.
//  Copyright © 2020 Skymatic GmbH. All rights reserved.
//

import CloudAccessPrivate
import CloudAccessPrivateCore
import ObjectiveDropboxOfficial
import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		guard let dbURL = CryptomatorDatabase.sharedDBURL else {
			// MARK: Handle error
			print("dbURL is nil")
			return false
		}
		do {
			let dbPool = try CryptomatorDatabase.openSharedDatabase(at: dbURL)
			CryptomatorDatabase.shared = try CryptomatorDatabase(dbPool)
		} catch {
			// MARK: Handle error

			print("Error while initializing the CryptomatorDatabase: \(error)")
			return false
		}
		window = UIWindow(frame: UIScreen.main.bounds)
		let navigationController = UINavigationController(rootViewController: GoogleDriveStartViewController())
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		if url.scheme == CloudAccessSecrets.dropboxURLScheme {
			let canHandle = DBClientsManager.handleRedirectURL(url) { authResult in
				guard let authResult = authResult else {
					return
				}
				if authResult.isSuccess() {
					let tokenUid = authResult.accessToken.uid
					let credential = DropboxCredential(tokenUid: tokenUid)
					DropboxCloudAuthenticator.pendingAuthentication?.fulfill(credential)
				} else if authResult.isCancel() {
					DropboxCloudAuthenticator.pendingAuthentication?.reject(DropboxAuthenticationError.userCanceled)
				} else if authResult.isError() {
					DropboxCloudAuthenticator.pendingAuthentication?.reject(authResult.nsError)
				}
			}
			return canHandle
		}
		return true
	}
}
