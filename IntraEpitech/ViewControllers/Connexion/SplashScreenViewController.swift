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

	override func viewDidLoad() {
		super.viewDidLoad()

		self.setNeedsStatusBarAppearanceUpdate()
		
		statusLabel.textColor = UIColor.whiteColor()
		statusLabel.text = ""
		self.view.backgroundColor = UIUtils.backgroundColor()

		if (UserPreferences.checkIfWantsDownloadingExists()) {
			app.canDownload = UserPreferences.getWantsDownloading()
		}
		if (UserPreferences.checkIfDefaultCalendarExists()) {
			app.defaultCalendar = UserPreferences.getDefaultCalendar()
		}
	}

	override func viewDidAppear(animated: Bool) {

		statusLabel.text = NSLocalizedString("GettingUserData", comment: "")
		MJProgressView.instance.showProgress(self.view, white: true)
		UserApiCalls.getUserData(ApplicationManager.sharedInstance.currentLogin!) { (isOk: Bool, s: String) in
		 self.statusLabel.text = NSLocalizedString("FinishedGettingUserData", comment: "")
			if (!isOk) {
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: s) {
					self.goBackToLogin()
				}

			} else {
				self.statusLabel.text = NSLocalizedString("DownloadingPicture", comment: "")
				//ImageDownloader.downloadFrom(link: (ApplicationManager.sharedInstance.user?.imageUrl!)!) {
				//	self.statusLabel.text = NSLocalizedString("GettingUserHistory", comment: "")
				UserApiCalls.getUserHistory() { (isOk: Bool, s: String) in
					self.statusLabel.text = NSLocalizedString("FinishedGettingUserHistory", comment: "")
					MJProgressView.instance.hideProgress()
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: s) {
							self.goBackToLogin()
						}

					} else {
						let storyboard = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
						let vc = storyboard.instantiateInitialViewController()
						self.presentViewController(vc!, animated: true, completion: nil)
					}
				}
				//}
				if (UserPreferences.checkSemestersExist() == true) {
					ApplicationManager.sharedInstance.planningSemesters = UserPreferences.getSemesters()
				}
			}
		}

	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}

	func goBackToLogin() {
		UserPreferences.deleteData()
		ApplicationManager.sharedInstance.resetInstance()
		self.dismissViewControllerAnimated(true, completion: nil)
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

}
