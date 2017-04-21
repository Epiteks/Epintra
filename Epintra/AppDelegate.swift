//
//  AppDelegate.swift
//  Epintra
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator
import SwiftyBeaver
import RxSwift

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

    let disposeBag = DisposeBag()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		// Configure tracker from GoogleService-Info.plist.

		let navigationBarAppearace = UINavigationBar.appearance()
		navigationBarAppearace.tintColor = UIUtils.backgroundColor
		
		let console = ConsoleDestination()
		
		console.levelColor.verbose = "🗣 "
		console.levelColor.debug = "👻 "
		console.levelColor.info = "🤖 "
		console.levelColor.warning = "🙀 "
		console.levelColor.error = "👺 "
        
		log.addDestination(console)
        
		NetworkActivityIndicatorManager.shared.isEnabled = true

        self.window = UIWindow(frame: UIScreen.main.bounds)
        var initialViewController: UIViewController
        if KeychainUtil.getCredentials()?.token != nil {
            let sb: UIStoryboard = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
            initialViewController = sb.instantiateInitialViewController()!
        } else {
            //If not logged in then show LoginViewController
            let sb = UIStoryboard(name: "ConnexionStoryboard", bundle: nil)
            initialViewController = sb.instantiateInitialViewController()!
        }
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        self.checkServersAvailability()

        // Check token and credentials
        guard let credentials = KeychainUtil.getCredentials() else {
            return
        }

        // If user does not exist, we create it
        if ApplicationManager.sharedInstance.user == nil {
            ApplicationManager.sharedInstance.user = Variable<User>(User(login: credentials.email))
        }

        // Check token validity
        if let tkn = credentials.token {
            ApplicationManager.sharedInstance.token = tkn
            // Check token validity.
            // If not valid, generate it.
            UsersRequests.getPhotoURL(credentials.email)
                .single()
                .subscribe(onNext: { [weak self] result in
                    switch result {
                    case .success(_): break // Token still valid
                    case .failure(_): // Token not valid. Update it if we can.
                        self?.updateToken(credentials)
                    }
                }).addDisposableTo(self.disposeBag)
        }
    }

    private func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    private func goToLoginViewController() {
        let vc = UIStoryboard(name: "ConnexionStoryboard", bundle: nil).instantiateInitialViewController()!
        self.getTopViewController()?.present(vc, animated: true, completion: nil)
    }

    private func checkServersAvailability() {

        if let topController = self.getTopViewController() {

            MiscRequests.getAPIStatus().single()
                .subscribe(onNext: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        topController.showError(withMessage: error.message)
                    }
                }).addDisposableTo(self.disposeBag)

            MiscRequests.getIntraStatus().single()
                .subscribe(onNext: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        topController.showError(withMessage: error.message)
                    }
                }).addDisposableTo(self.disposeBag)
        }
    }

    private func updateToken(_ credentials: Authentication) {

        guard let password = credentials.password else {
            // Authenticated with OAuth. Cannot generate new token manually.
            // Should go back to LoginViewController
            self.goToLoginViewController()
            return
        }

        UsersRequests.auth(credentials.email, password: password)
            .single()
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    // Authentication failed, send back to LoginViewController
                    self.goToLoginViewController()
                    break
                }
            }).addDisposableTo(self.disposeBag)
    }

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

}
