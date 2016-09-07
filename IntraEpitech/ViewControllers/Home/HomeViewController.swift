//
//  HomeViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import Haneke

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var alertTableView: UITableView!
	
	var currentUser :User?
	var tableFooterSave: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		currentUser = ApplicationManager.sharedInstance.user!
		
		self.generateBackgroundView()
		self.tableFooterSave = self.alertTableView.tableFooterView
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Notifications", comment: "")
	}
	
	override func viewDidAppear(animated: Bool) {
		
		let app = ApplicationManager.sharedInstance
		
		// If it's 5 minutes from the last call
		if (NSDate().timeIntervalSince1970 > ((300000) + app.lastUserApiCall!)) {
			refreshData(self)
		}
	}
	
	func refreshData(sender:AnyObject) {
		
		let dispatchGroup = dispatch_group_create()
		
		let historySave = currentUser?.history
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
			dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
				self.userDataCall(dispatchGroup)
				self.userHistoryCall(dispatchGroup)
			})
			dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
				dispatch_async(dispatch_get_main_queue(), {
					// Update tableview if changes
					
					if (historySave! != self.currentUser!.history!) {
						self.generateBackgroundView()
						self.alertTableView.reloadData()
					}
					
				})
			})
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func userDataCall(group: dispatch_group_t) {
		dispatch_group_enter(group)
		userRequests.getCurrentUserData { result in
			
			switch (result) {
			case .Success(_):
				logger.info("Get user data ok")
				break
			case .Failure(let error):
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				break
			}
			dispatch_group_leave(group)
		}
	}
	
	func userHistoryCall(group: dispatch_group_t) {
		dispatch_group_enter(group)
		userRequests.getHistory() { result in
			switch (result) {
			case .Success(_):
				logger.info("Get user history")
				break
			case .Failure(let error):
				MJProgressView.instance.hideProgress()
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) {}
				}
				break
			}
			dispatch_group_leave(group)
		}
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var rows = currentUser?.history?.count
		
		if rows == nil {
			rows = 0
		}
		
		return rows!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		
		var cell = UITableViewCell()
		cell = tableView.dequeueReusableCellWithIdentifier("alertCell")!
		
		cell.tag = indexPath.row + 100
		
		let profileImage = cell.viewWithTag(1) as! UIImageView
		let content = cell.viewWithTag(2) as! UILabel
		let date = cell.viewWithTag(3) as! UILabel
		
		let history = currentUser?.history![indexPath.row]
		
		profileImage.image = UIImage(named: "userProfile")
		
		if (history!.userPicture!.characters.count > 0) {
			if let img = ApplicationManager.sharedInstance.downloadedImages![history!.userPicture!] {
				if (cell.tag == (indexPath.row + 100)) {
					profileImage.image = img
				}
			} else {
				ImageDownloader.downloadFrom(link: history!.userPicture!) {_ in 
					if let img = ApplicationManager.sharedInstance.downloadedImages![history!.userPicture!] {
						if (cell.tag == (indexPath.row + 100)) {
							profileImage.image = img
						}
						profileImage.cropToSquare()
						profileImage.toCircle()
					}
				}
			}
		}
		
		profileImage.cropToSquare()
		profileImage.toCircle()
		
		content.text = history?.title!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
		
		date.text = (history?.userName!)! + " - " +  (history?.date!.toAlertString())!
		
		return cell
	}
	
	func generateBackgroundView() {
		
		let usr = ApplicationManager.sharedInstance.user!
		
		if usr.history != nil && usr.history?.count <= 0 {
			self.alertTableView.tableFooterView = UIView()
			let noData = NoDataView(info:  NSLocalizedString("NoNotification", comment: ""))
			self.alertTableView.backgroundView = noData
		} else {
			self.alertTableView.tableFooterView = self.tableFooterSave
			self.alertTableView.backgroundView = nil
		}
	}
}
