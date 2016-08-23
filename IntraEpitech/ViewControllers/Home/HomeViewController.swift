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
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	@IBOutlet weak var profileViewContainer: UIView!
	@IBOutlet weak var alertTableView: UITableView!
	
	var profileImageView :UIImageView!
	var creditsTitleLabel :UILabel!
	var creditsLabel :UILabel!
	var spicesLabel :UILabel!
	var logLabel :UILabel!
	var gpaTitleLabel :UILabel!
	var gpaLabel :UILabel!
	var	gpaTypeLabel :UILabel!
	var currentUser :User?
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		currentUser = ApplicationManager.sharedInstance.user!
		
		loadProfileView()
		
		if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl!)!] {
			self.profileImageView.image = img
			self.profileImageView.cropToSquare()
		}
		
		profileImageView.toCircle()
		profileImageView.cropToSquare()
		
		setUIElements()
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(HomeViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.alertTableView.addSubview(refreshControl)
		
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Notifications", comment: "")
	}
	
	override func viewDidAppear(animated: Bool) {
		
		let app = ApplicationManager.sharedInstance
		
		if (NSDate().timeIntervalSince1970 > ((5 * 60 * 1000) + app.lastUserApiCall!)) {
			refreshData(self)
		}
	}
	
	func refreshData(sender:AnyObject) {
		
		UserApiCalls.getUserData(ApplicationManager.sharedInstance.currentLogin!) { (isOk :Bool, s :String) in
		 
			if (!isOk) {
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: s) {}
				self.refreshControl.endRefreshing()
				self.alertTableView.reloadData()
			} else {
				ImageDownloader.downloadFrom(link: (ApplicationManager.sharedInstance.user?.imageUrl!)!) {_ in 
					UserApiCalls.getUserHistory() { (isOk :Bool, s :String) in
						MJProgressView.instance.hideProgress()
						if (!isOk) {
							ErrorViewer.errorPresent(self, mess: s) {}
						}
						self.refreshControl.endRefreshing()
						self.alertTableView.reloadData()
					}
				}
			}
		}
		
		
		
		
		/*UserApiCalls.getUserHistory() { (isOk :Bool, s :String) in
		self._refreshControl.endRefreshing()
		self._alertTableView.reloadData()
		}*/
	}
	
	func loadProfileView() {
		let nibView = NSBundle.mainBundle().loadNibNamed("ProfileView", owner: self, options: nil)[0] as! UIView
		profileViewContainer.addSubview(nibView)
		
		profileImageView = nibView.viewWithTag(1) as? UIImageView
		creditsTitleLabel = nibView.viewWithTag(2) as? UILabel!
		creditsLabel = nibView.viewWithTag(3) as? UILabel!
		spicesLabel = nibView.viewWithTag(4) as? UILabel!
		logLabel = nibView.viewWithTag(5) as? UILabel!
		gpaTitleLabel = nibView.viewWithTag(6) as? UILabel!
		gpaLabel = nibView.viewWithTag(7) as? UILabel!
		gpaTypeLabel = nibView.viewWithTag(8) as? UILabel!
	}
	
	func setUIElements() {
		creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
		creditsLabel.text = String(currentUser!.credits!)
		spicesLabel.text =  currentUser!.spices!.currentSpices + " " + NSLocalizedString("spices", comment: "")
		logLabel.text = "Log : " + String(currentUser!.log!.timeActive)
		logLabel.textColor = currentUser?.log?.getColor()
		
		
		let gpa = currentUser?.getLatestGPA()
		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		gpaLabel.text = gpa?.value
		gpaTypeLabel.text = gpa?.cycle
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		
		let rows = currentUser?.history?.count
		
		if (rows == 0) {
			let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
			
			messageLabel.text =  NSLocalizedString("NoAlerts", comment: "")
			messageLabel.textColor = UIColor.blackColor()
			messageLabel.numberOfLines = 0
			messageLabel.textAlignment = .Center
			messageLabel.font = UIFont.systemFontOfSize(13)
			messageLabel.sizeToFit()
			
			alertTableView.backgroundView = messageLabel
			alertTableView.separatorStyle = UITableViewCellSeparatorStyle.None
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
}
