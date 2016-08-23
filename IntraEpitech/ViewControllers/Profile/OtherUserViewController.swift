//
//  OtherUserViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 07/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import MessageUI
import AddressBookUI
import Contacts
import ContactsUI

class OtherUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, CNContactViewControllerDelegate {
	
	@IBOutlet weak var profileViewContainer: UIView!
	
	var profileImageView :UIImageView!
	var creditsTitleLabel :UILabel!
	var creditsLabel :UILabel!
	var spicesLabel :UILabel!
	var logLabel :UILabel!
	var gpaTitleLabel :UILabel!
	var gpaLabel :UILabel!
	var	gpaTypeLabel :UILabel!
	var currentUser :User?
	
	var isModuleDownloading :Bool?
	var isMarksDownloading :Bool?
	var isFlagsDownloading :Bool?
	
	var flags :[Flags]?
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	@IBOutlet weak var actionButton: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		segmentedControl.setTitle(NSLocalizedString("Modules", comment: ""), forSegmentAtIndex: 0)
		segmentedControl.setTitle(NSLocalizedString("Marks", comment: ""), forSegmentAtIndex: 1)
		segmentedControl.setTitle(NSLocalizedString("Flags", comment: ""), forSegmentAtIndex: 2)
		loadProfileView()
		setUIElements()
		self.title = currentUser?.login
		
		self.segmentedControl.tintColor = UIUtils.backgroundColor()
	}
	
	override func viewWillAppear(animated: Bool) {
		isMarksDownloading = true
		MarksApiCalls.getMarksFor(user: self.currentUser!.login!) { (isOk :Bool, resp :[Mark]?, mess :String) in
			self.isMarksDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			} else {
				self.currentUser?.marks = resp
				if (self.segmentedControl.selectedSegmentIndex == 1) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
		self.isModuleDownloading = true
		ModulesApiCalls.getRegisteredModulesFor(user: self.currentUser!.login!) { (isOk :Bool, resp :[Module]?, mess :String) in
			self.isModuleDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			} else {
				self.currentUser?.modules = resp!
				if (self.segmentedControl.selectedSegmentIndex == 0) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
		self.isFlagsDownloading = true
		UserApiCalls.getUserFlags(self.currentUser!.login!) { (isOk :Bool, resp :[Flags]?, mess :String) in
			self.isFlagsDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.flags = resp!
				if (self.segmentedControl.selectedSegmentIndex == 2) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		MJProgressView.instance.showProgress(self.tableView, white: false)
		self.profileImageView.image = UIImage(named: "userProfile")
		ImageDownloader.downloadFrom(link: (currentUser?.imageUrl)!) {_ in 
			if let img = ApplicationManager.sharedInstance.downloadedImages![self.currentUser!.imageUrl!] {
				self.profileImageView.image = img
				self.profileImageView.cropToSquare()
			}
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		profileImageView.cropToSquare()
		profileImageView.toCircle()
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	@IBAction func segmentedChanged(sender: UISegmentedControl) {
		
		if (sender.selectedSegmentIndex == 0 && self.isModuleDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else if (sender.selectedSegmentIndex == 1 && self.isMarksDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else if (sender.selectedSegmentIndex == 2 && self.isFlagsDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else {
			MJProgressView.instance.hideProgress()
		}
		
		self.tableView.reloadData()
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (segmentedControl.selectedSegmentIndex == 2) {
			return (flags?.count)!
		}
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if ((currentUser?.modules == nil && segmentedControl.selectedSegmentIndex == 0)
			|| (currentUser?.marks == nil && segmentedControl.selectedSegmentIndex == 1)
			|| (flags == nil && segmentedControl.selectedSegmentIndex == 2)) {
			self.tableView.separatorStyle = .None
			return 0
		}
		self.tableView.separatorStyle = .SingleLine
		switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			return (currentUser?.modules?.count)!
		case 1:
			return (currentUser?.marks?.count)!
		case 2:
			let cnt = flags![section].modules.count
			return (cnt == 0 ? 1 : cnt)
		default:
			return 0
		}
		
		//		return (segmentedControl.selectedSegmentIndex == 0 ? currentUser?.modules!.count : currentUser?.marks!.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
		
		if (segmentedControl.selectedSegmentIndex == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("moduleCell")
			
			let titleLabel = cell?.viewWithTag(1) as! UILabel
			let creditsLabel = cell?.viewWithTag(2) as! UILabel
			let gradeLabel = cell?.viewWithTag(3) as! UILabel
			
			let module = currentUser?.modules![indexPath.row]
			
			creditsLabel.text = NSLocalizedString("AvailableCredits", comment: "") + module!.credits!
			if (module!.grade != nil) {
				gradeLabel.text = module!.grade!
			}
			titleLabel.text = module!.title!
		} else if (segmentedControl.selectedSegmentIndex == 1) {
			
			cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
			
			let actiTitle = cell?.viewWithTag(1) as! UILabel
			let moduleTitle = cell?.viewWithTag(2) as! UILabel
			let markLabel = cell?.viewWithTag(3) as! UILabel
			
			let mark = currentUser?.marks![indexPath.row]
			
			actiTitle.text = mark?.title!
			moduleTitle.text = mark?.titleModule!
			markLabel.text = mark?.finalNote!
		} else {
			if (flags![indexPath.section].modules.count > 0) {
				cell = tableView.dequeueReusableCellWithIdentifier("flagCell")!
				let titleLabel = cell!.viewWithTag(1) as! UILabel
				let gradeLabel = cell!.viewWithTag(2) as! UILabel
				let module = flags![indexPath.section].modules[indexPath.row]
				titleLabel.text = module.title
				gradeLabel.text = module.grade
			} else if (indexPath.section > 0 && flags![indexPath.section].modules.count == 0) {
				cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
				let titleLabel = cell!.viewWithTag(1) as! UILabel
				titleLabel.text = NSLocalizedString("NoFlag", comment: "")
			}
			
		}
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	@IBAction func actionButtonClicked(sender: AnyObject) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
			
		}
		alertController.addAction(cancelAction)
		
		if (currentUser?.phone != nil && currentUser?.phone?.characters.count > 0) {
			
			let callAction = UIAlertAction(title: NSLocalizedString("Call", comment: "") + " " + (currentUser?.phone!)!, style: .Default) { (action) in
				
				let nbr = self.currentUser?.phone!.stringByReplacingOccurrencesOfString(" ", withString: "")
				
				let numberToCall = "tel://" + nbr!
				UIApplication.sharedApplication().openURL(NSURL(string: numberToCall)!)
			}
			alertController.addAction(callAction)
		}
		
		let emailAction = UIAlertAction(title: NSLocalizedString("Email", comment: ""), style: .Default) { (action) in
			
			if (MFMailComposeViewController.canSendMail()) {
				let mailComposerVC = MFMailComposeViewController()
				mailComposerVC.mailComposeDelegate = self
				mailComposerVC.setToRecipients([(self.currentUser?.internalEmail!)!])
				self.presentViewController(mailComposerVC, animated: true, completion: nil)
			}
			
		}
		alertController.addAction(emailAction)
		
		self.presentViewController(alertController, animated: true) {
		}
		
	}
	
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if segmentedControl.selectedSegmentIndex != 2 {
			return nil
		}
		
		var str = ""
		
		switch section {
		case 0 : str = "Medals"
			break
		case 1 : str = "Remarkables"
			break
		case 2 : str = "Difficulty"
			break
		case 3 : str = "Ghost"
			break
		default: str = ""
			break
		}
		return NSLocalizedString(str, comment: "")
	}
}
