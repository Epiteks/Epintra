//
//  SplashScreenViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

	@IBOutlet weak var statusLabel: UILabel!
	
	var errorDuringFetching = false
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		statusLabel.textColor = UIColor.white
		statusLabel.text = ""
		self.view.backgroundColor = UIUtils.backgroundColor
		
		if (UserPreferences.checkIfWantsDownloadingExists()) {
			ApplicationManager.sharedInstance.canDownload = UserPreferences.getWantsDownloading()
		}
		if (UserPreferences.checkIfDefaultCalendarExists()) {
			ApplicationManager.sharedInstance.defaultCalendar = UserPreferences.getDefaultCalendar()
		}

	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		MJProgressView.instance.showProgress(self.view, white: true)
		
		fetchAllData()
		
		return
	}
	
	func fetchAllData() {
		
		let dispatchGroup = DispatchGroup()
		
		DispatchQueue.global(qos: .utility).async {
		
			DispatchQueue.global(qos: .utility).async(group: dispatchGroup, execute: {
				self.userDataCall(dispatchGroup)
				self.userHistoryCall(dispatchGroup)
			})
			dispatchGroup.notify(queue: DispatchQueue.global(qos: .utility), execute: {
				DispatchQueue.main.async(execute: {
					if self.errorDuringFetching == true {
						self.goBackToLogin()
					} else {
						let storyboard = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
						let vc = storyboard.instantiateInitialViewController()
						self.present(vc!, animated: true, completion: nil)
					}
				})
			})
		}
	}
	
	func goBackToLogin() {
		UserPreferences.deleteData()
		ApplicationManager.sharedInstance.resetInstance()
		self.dismiss(animated: true, completion: nil)
	}
	
	func userDataCall(_ group: DispatchGroup) {
		group.enter()
		usersRequests.getCurrentUserData { result in
			self.setStatusLabel(message: "FetchedUserData")
			switch (result) {
			case .success(_):
				log.info("Get user data ok")
				group.leave()
				break
			case .failure(let error):
				DispatchQueue.main.async {
					self.errorDuringFetching = true
					MJProgressView.instance.hideProgress()
					if error.message != nil {
						ErrorViewer.errorPresent(self, mess: error.message!) {
							group.leave()
						}
					} else {
						ErrorViewer.errorPresent(self, mess: NSLocalizedString("unknownApiError", comment: "")) {
							group.leave()
						}
					}
				}
				break
			}
		}
	}
	
	func userHistoryCall(_ group: DispatchGroup) {
		group.enter()
		setStatusLabel(message: "GettingUserHistory")
		usersRequests.getHistory { result in
			self.setStatusLabel(message: "FetchedHistory")
			switch (result) {
			case .success(_):
				log.info("Have user history")
				group.leave()
				break
			case .failure(let error):
				DispatchQueue.main.async {
					self.errorDuringFetching = true
					MJProgressView.instance.hideProgress()
					if error.message != nil {
						ErrorViewer.errorPresent(self, mess: error.message!) {
							group.leave()
						}
					} else {
						ErrorViewer.errorPresent(self, mess: NSLocalizedString("unknownApiError", comment: "")) {
							group.leave()
						}
					}
				}
				break
			}
			
		}
	}
	
    func setStatusLabel(message: String) {
		DispatchQueue.main.async {
			self.statusLabel.text = NSLocalizedString(message, comment: "")
		}
	}
}
