//
//  ProfileViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SAConfettiView

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var searchBarButton: UIBarButtonItem!
	@IBOutlet weak var menuButton: UIBarButtonItem!
	@IBOutlet weak var profileViewContainer: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	var currentUser :User?
	
	var files :[File]?
	var flags :[Flags]?
	var webViewData :File?
	var refreshControl = UIRefreshControl()
	
	var confettiView: SAConfettiView!
	
	
	override func viewDidLoad() {
		
		currentUser = ApplicationManager.sharedInstance.user
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		UserApiCalls.getUserDocuments() { (isOk :Bool, resp :[File]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.files = resp!
				UserApiCalls.getUserFlags(ApplicationManager.sharedInstance.user?.login) { (isOk :Bool, resp :[Flags]?, mess :String) in
					
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					} else {
						self.flags = resp!
						self.tableView.reloadData()
					}
					MJProgressView.instance.hideProgress()
				}
			}	
		}
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(ProfileViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Profile", comment: "")
	}
	
	func refreshData(sender :AnyObject) {
		UserApiCalls.getUserDocuments() { (isOk :Bool, resp :[File]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.files = resp!
				UserApiCalls.getUserFlags(ApplicationManager.sharedInstance.user?.login) { (isOk :Bool, resp :[Flags]?, mess :String) in
					
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					} else {
						self.flags = resp!
						self.tableView.reloadData()
					}
					MJProgressView.instance.hideProgress()
					self.refreshControl.endRefreshing()
				}
			}
		}
		
	}
	
	@IBAction func searchProfileButtonPressed(sender: AnyObject) {
		//performSegueWithIdentifier("searchProfileSegue", sender: self)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 6
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var res = 0
		
		if (flags == nil || files == nil) { return 0 }
		
		if section == 0 {
			res = 1
		} else if (section == 1) {
			if (files?.count == 0) {
				res = 1
			} else { res = (files?.count)! }
		} else {
			if ((flags![section - 2].modules.count) == 0) {
				res = 1
			} else { res = (flags![section - 2].modules.count) }
		}
		
		return res
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		
		if (indexPath.section == 0) { // Profile Cell, the first one
			cell = tableView.dequeueReusableCellWithIdentifier("profileCell")! as! ProfileTableViewCell
		} else if (indexPath.section == 1 && files?.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = files![indexPath.row].title!
			cell.accessoryType = .DisclosureIndicator
		} else if (indexPath.section == 1 && files?.count == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoFile", comment: "")
		} else if (flags![indexPath.section - 2].modules.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("flagCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			let gradeLabel = cell.viewWithTag(2) as! UILabel
			let module = flags![indexPath.section - 2].modules[indexPath.row]
			titleLabel.text = module.title
			gradeLabel.text = module.grade
		} else if (indexPath.section > 1 && flags![indexPath.section - 2].modules.count == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoFlag", comment: "")
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 110
		} else {
			return 44
		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		var str = ""
		
		switch section {
		case 1 : str = "Files"
			break
		case 2 : str = "Medals"
			break
		case 3 : str = "Remarkables"
			break
		case 4 : str = "Difficulty"
			break
		case 5 : str = "Ghost"
			break
		default: str = ""
			break
		}
		return NSLocalizedString(str, comment: "")
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (indexPath.section == 1) {
			webViewData = files![indexPath.row]
			self.performSegueWithIdentifier("webViewSegue", sender: self)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "webViewSegue") {
			let vc :WebViewViewController = segue.destinationViewController as! WebViewViewController
			vc.file = webViewData!
			vc.isUrl = true
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (confettiView.isActive()) {
			confettiView.stopConfetti()
			confettiView.removeFromSuperview()
		}
	}
}
