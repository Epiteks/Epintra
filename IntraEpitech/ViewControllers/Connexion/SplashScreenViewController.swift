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
		
		statusLabel.textColor = UIColor.whiteColor()
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
	
	override func viewDidAppear(animated: Bool) {
		
		
		MJProgressView.instance.showProgress(self.view, white: true)
		
		fetchAllData()
		
		return
	}
	
	//	override func preferredStatusBarStyle() -> UIStatusBarStyle {
	//		return UIStatusBarStyle.LightContent
	//	}
	
	func fetchAllData() {
		
		let dispatchGroup = dispatch_group_create()
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
			dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
				self.statusLabel.text = NSLocalizedString("GettingData", comment: "")
				self.userDataCall(dispatchGroup)
				self.userHistoryCall(dispatchGroup)
				self.getUserImage(dispatchGroup)
			})
			dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
				dispatch_async(dispatch_get_main_queue(), {
					if self.errorDuringFetching == true {
						self.goBackToLogin()
					} else {
						let storyboard = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
						let vc = storyboard.instantiateInitialViewController()
						self.presentViewController(vc!, animated: true, completion: nil)
					}
				})
			})
		})
		
	}
	
	func goBackToLogin() {
		UserPreferences.deleteData()
		ApplicationManager.sharedInstance.resetInstance()
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func userDataCall(group: dispatch_group_t) {
		dispatch_group_enter(group)
		userRequests.getCurrentUserData { result in
			self.statusLabel.text = NSLocalizedString("FetchedUserData", comment: "")
			switch (result) {
			case .Success(_):
				logger.info("Get user data ok")
				break
			case .Failure(let error):
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				self.errorDuringFetching = true
				break
			}
			dispatch_group_leave(group)
		}
	}
	
	func userHistoryCall(group: dispatch_group_t) {
		dispatch_group_enter(group)
		self.statusLabel.text = NSLocalizedString("GettingUserHistory", comment: "")
		userRequests.getHistory() { result in
			self.statusLabel.text = NSLocalizedString("FetchedHistory", comment: "")
			switch (result) {
			case .Success(_):
				logger.info("Get user history")
				break
			case .Failure(let error):
				MJProgressView.instance.hideProgress()
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) {}
				}
				self.errorDuringFetching = true
				break
			}
			dispatch_group_leave(group)
		}
	}
	
	func getUserImage(group: dispatch_group_t) {
		dispatch_group_enter(group)
		
		let url = configurationInstance.profilePictureURL + app.currentLogin! + ".bmp"
		
		ImageDownloader.downloadFrom(link: url) { result in
			switch(result) {
			case .Success(_):
				logger.info("Image downloaded")
				break
			case .Failure(let error):
				if (error.type == Error.APIError) {
					//ErrorViewer.errorPresent(self, mess: NSLocalizedString("unknownApiError", comment: "")) { }
				}
				break
			}
			dispatch_group_leave(group)
		}
	}
}
