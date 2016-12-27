//
//  HomeViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

fileprivate func < <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var alertTableView: UITableView!
	
	var currentUser: User?
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
	
	override func viewDidAppear(_ animated: Bool) {
		
		let app = ApplicationManager.sharedInstance
		
		// If it's 5 minutes from the last call
		if (Date().timeIntervalSince1970 > ((300000) + app.lastUserApiCall!)) {
			refreshData(self)
		}
	}
	
	func refreshData(_ sender:AnyObject) {
		
		let dispatchGroup = DispatchGroup()
		
		let historySave = currentUser?.history
		
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
			DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(group: dispatchGroup, execute: {
				self.userDataCall(dispatchGroup)
				self.userHistoryCall(dispatchGroup)
			})
			dispatchGroup.notify(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high), execute: {
				DispatchQueue.main.async(execute: {
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
	
	func userDataCall(_ group: DispatchGroup) {
		group.enter()
		usersRequests.getCurrentUserData { result in
			
			switch (result) {
			case .success(_):
				log.info("Get user data ok")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				break
			}
			group.leave()
		}
	}
	
	func userHistoryCall(_ group: DispatchGroup) {
		group.enter()
		usersRequests.getHistory() { result in
			switch (result) {
			case .success(_):
				log.info("Get user history")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) {}
				}
				break
			}
			group.leave()
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var rows = currentUser?.history?.count
		
		if rows == nil {
			rows = 0
		}
		
		return rows!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		cell = tableView.dequeueReusableCell(withIdentifier: "alertCell")!
		
		cell.tag = (indexPath as NSIndexPath).row + 100
		
		let profileImage = cell.viewWithTag(1) as! UIImageView
		let content = cell.viewWithTag(2) as! UILabel
		let date = cell.viewWithTag(3) as! UILabel
		
		let history = currentUser?.history![(indexPath as NSIndexPath).row]
		
		profileImage.image = UIImage(named: "userProfile")
		
		if (history!.userPicture!.characters.count > 0) {
			if let img = ApplicationManager.sharedInstance.downloadedImages![history!.userPicture!] {
				if (cell.tag == ((indexPath as NSIndexPath).row + 100)) {
					profileImage.image = img
				}
			} else {
				ImageDownloader.downloadFrom(link: history!.userPicture!) {_ in 
					if let img = ApplicationManager.sharedInstance.downloadedImages![history!.userPicture!] {
						if (cell.tag == ((indexPath as NSIndexPath).row + 100)) {
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
		
		content.text = history?.title!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
		
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
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80.0
	}
}
