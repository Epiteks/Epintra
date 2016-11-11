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
	
	let app = ApplicationManager.sharedInstance
	
	var errorDuringFetching = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//self.setNeedsStatusBarAppearanceUpdate()
		
		statusLabel.textColor = UIColor.white
		statusLabel.text = ""
		self.view.backgroundColor = UIUtils.backgroundColor()
		
		if (UserPreferences.checkIfWantsDownloadingExists()) {
			app.canDownload = UserPreferences.getWantsDownloading()
		}
		if (UserPreferences.checkIfDefaultCalendarExists()) {
			app.defaultCalendar = UserPreferences.getDefaultCalendar()
		}
		if (UserPreferences.checkSemestersExist() == true) {
			ApplicationManager.sharedInstance.planningSemesters = UserPreferences.getSemesters()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		
		MJProgressView.instance.showProgress(self.view, white: true)
		
		fetchAllData()
		
		return
	}
	
	//	override func preferredStatusBarStyle() -> UIStatusBarStyle {
	//		return UIStatusBarStyle.LightContent
	//	}
	
	func fetchAllData() {
		
		let dispatchGroup = DispatchGroup()
		
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
			DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(group: dispatchGroup, execute: {
				self.statusLabel.text = NSLocalizedString("GettingData", comment: "")
				self.userDataCall(dispatchGroup)
				self.userHistoryCall(dispatchGroup)
				self.getUserImage(dispatchGroup)
			})
			dispatchGroup.notify(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high), execute: {
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
		})
		
	}
	
	func goBackToLogin() {
		UserPreferences.deleteData()
		ApplicationManager.sharedInstance.resetInstance()
		self.dismiss(animated: true, completion: nil)
	}
	
	func userDataCall(_ group: DispatchGroup) {
		group.enter()
		userRequests.getCurrentUserData { result in
			self.statusLabel.text = NSLocalizedString("FetchedUserData", comment: "")
			switch (result) {
			case .success(_):
				log.info("Get user data ok")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				self.errorDuringFetching = true
				break
			}
			group.leave()
		}
	}
	
	func userHistoryCall(_ group: DispatchGroup) {
		group.enter()
		self.statusLabel.text = NSLocalizedString("GettingUserHistory", comment: "")
		userRequests.getHistory() { result in
			self.statusLabel.text = NSLocalizedString("FetchedHistory", comment: "")
			switch (result) {
			case .success(_):
				log.info("Get user history")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) {}
				}
				self.errorDuringFetching = true
				break
			}
			group.leave()
		}
	}
	
	func getUserImage(_ group: DispatchGroup) {
		group.enter()
		
		let url = configurationInstance.profilePictureURL + app.currentLogin! + ".bmp"
		
		ImageDownloader.downloadFrom(link: url) { result in
			switch(result) {
			case .success(_):
				log.info("Image downloaded")
				break
			case .failure(let error):
				if (error.type == AppError.apiError) {
					//ErrorViewer.errorPresent(self, mess: NSLocalizedString("unknownApiError", comment: "")) { }
				}
				break
			}
			group.leave()
		}
	}
}
