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
	
	var profileImageView :UIImageView!
	var creditsTitleLabel :UILabel!
	var creditsLabel :UILabel!
	var spicesLabel :UILabel!
	var logLabel :UILabel!
	var gpaTitleLabel :UILabel!
	var gpaLabel :UILabel!
	var	gpaTypeLabel :UILabel!
	var currentUser :User?
	
	var files :[File]?
	var flags :[Flags]?
	var webViewData :File?
	var refreshControl = UIRefreshControl()
	
	var confettiView: SAConfettiView!
	
	
	override func viewDidLoad() {
		
		currentUser = ApplicationManager.sharedInstance.user
		
		loadProfileView()
		setUIElements()
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl!)!] {
			self.profileImageView.image = img
		}
		
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
		self.profileImageView.cropToSquare()
		self.profileImageView.toCircle()
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(ProfileViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(refreshControl)
		
		confettiConf()
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Profile", comment: "")
	}
	
	
	func confettiConf() {
		// Create confetti view
		confettiView = SAConfettiView(frame: self.view.bounds)
		
		// Set colors (default colors are red, green and blue)
		confettiView.colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
		                       UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
		                       UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
		                       UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
		                       UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
		
		// Set intensity (from 0 - 1, default intensity is 0.5)
		confettiView.intensity = 0.7
		
		// Set type
		//		confettiView.type = .Confetti
		
		if (Float(gpaLabel.text!) > 3.00 && Float(gpaLabel.text!) <= 3.50) {
			confettiView.type = .Star
		} else if (Float(gpaLabel.text!) > 3.50) {
			confettiView.type = .Image(UIImage(named: "cup")!)
		} else {
			
			confettiView.colors = [UIColor(hexString: "#6D4C41ff")!,
			                       UIColor(hexString: "#5D4037ff")!,
			                       UIColor(hexString: "#4E342Eff")!,
			                       UIColor(hexString: "#3E2723ff")!]
			
			confettiView.type = .Image(UIImage(named: "bug")!)
		}
	}
	
	
	// For custom image
	// confettiView.type = .Custom
	// confettiView.customImage = UIImage(named: "diamond")
	
	// Add subview
	//view.addSubview(confettiView)
	
	func gpaTapDetected(gesture :UIGestureRecognizer) {
		if (!confettiView.isActive()) {
			view.addSubview(confettiView)
			confettiView.startConfetti()
		}
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
		
		
		let singleTap = UITapGestureRecognizer(target: self, action:#selector(ProfileViewController.gpaTapDetected(_:)))
		singleTap.numberOfTapsRequired = 1
		gpaLabel.userInteractionEnabled = true
		gpaLabel.addGestureRecognizer(singleTap)
		
		let gpa = currentUser?.getLatestGPA()
		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		gpaLabel.text = gpa?.value
		gpaTypeLabel.text = gpa?.cycle
		
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var res = 0
		
		if (flags == nil || files == nil) { return 0 }
		
		if (section == 0) {
			if (files?.count == 0) {
				res = 1
			} else { res = (files?.count)! }
		} else {
			if ((flags![section - 1].modules.count) == 0) {
				res = 1
			} else { res = (flags![section - 1].modules.count) }
		}
		
		return res
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		
		if (indexPath.section == 0 && files?.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = files![indexPath.row].title!
			cell.accessoryType = .DisclosureIndicator
		} else if (indexPath.section == 0 && files?.count == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoFile", comment: "")
		} else if (flags![indexPath.section - 1].modules.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("flagCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			let gradeLabel = cell.viewWithTag(2) as! UILabel
			let module = flags![indexPath.section - 1].modules[indexPath.row]
			titleLabel.text = module.title
			gradeLabel.text = module.grade
		} else if (indexPath.section > 0 && flags![indexPath.section - 1].modules.count == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoFlag", comment: "")
		}
		
		return cell
	}
	
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		var str = ""
		
		switch section {
		case 0 : str = "Files"
			break
		case 1 : str = "Medals"
			break
		case 2 : str = "Remarkables"
			break
		case 3 : str = "Difficulty"
			break
		case 4 : str = "Ghost"
			break
		default: str = ""
			break
		}
		return NSLocalizedString(str, comment: "")
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (indexPath.section == 0) {
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
