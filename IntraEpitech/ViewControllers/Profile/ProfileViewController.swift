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
	
	@IBOutlet weak var _searchBarButton: UIBarButtonItem!
	@IBOutlet weak var menuButton: UIBarButtonItem!
	@IBOutlet weak var _profileViewContainer: UIView!
	@IBOutlet weak var _tableView: UITableView!
	
	var _profileImageView :UIImageView!
	var _creditsTitleLabel :UILabel!
	var _creditsLabel :UILabel!
	var _spicesLabel :UILabel!
	var _logLabel :UILabel!
	var _gpaTitleLabel :UILabel!
	var _gpaLabel :UILabel!
	var	_gpaTypeLabel :UILabel!
	var _currentUser :User?
	
	var _files :[File]?
	var _flags :[Flags]?
	var _webViewData :File?
	var _refreshControl = UIRefreshControl()
	
	var confettiView: SAConfettiView!
	
	
	override func viewDidLoad() {
		
		_currentUser = ApplicationManager.sharedInstance._user
		
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		
		loadProfileView()
		setUIElements()
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		if let img = ApplicationManager.sharedInstance._downloadedImages![(ApplicationManager.sharedInstance._user?._imageUrl!)!]
		{
			self._profileImageView.image = img
		}
		
		UserApiCalls.getUserDocuments() { (isOk :Bool, resp :[File]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._files = resp!
				UserApiCalls.getUserFlags(ApplicationManager.sharedInstance._user?._login) { (isOk :Bool, resp :[Flags]?, mess :String) in
					
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					}
					else {
						self._flags = resp!
						self._tableView.reloadData()
					}
					MJProgressView.instance.hideProgress()
				}
			}	
		}
		self._profileImageView.cropToSquare()
		self._profileImageView.toCircle()
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: #selector(ProfileViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
		
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
		
		if (Float(_gpaLabel.text!) > 3.00 && Float(_gpaLabel.text!) <= 3.50) {
			confettiView.type = .Star
		}
		else if (Float(_gpaLabel.text!) > 3.50) {
			confettiView.type = .Image(UIImage(named: "cup")!)
		}
		else {
			
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
			}
			else {
				self._files = resp!
				UserApiCalls.getUserFlags(ApplicationManager.sharedInstance._user?._login) { (isOk :Bool, resp :[Flags]?, mess :String) in
					
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					}
					else {
						self._flags = resp!
						self._tableView.reloadData()
					}
					MJProgressView.instance.hideProgress()
					self._refreshControl.endRefreshing()
				}
			}
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Profile")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	@IBAction func searchProfileButtonPressed(sender: AnyObject) {
		//performSegueWithIdentifier("searchProfileSegue", sender: self)
	}
	
	func loadProfileView() {
		let nibView = NSBundle.mainBundle().loadNibNamed("ProfileView", owner: self, options: nil)[0] as! UIView
		_profileViewContainer.addSubview(nibView)
		
		_profileImageView = nibView.viewWithTag(1) as? UIImageView
		_creditsTitleLabel = nibView.viewWithTag(2) as? UILabel!
		_creditsLabel = nibView.viewWithTag(3) as? UILabel!
		_spicesLabel = nibView.viewWithTag(4) as? UILabel!
		_logLabel = nibView.viewWithTag(5) as? UILabel!
		_gpaTitleLabel = nibView.viewWithTag(6) as? UILabel!
		_gpaLabel = nibView.viewWithTag(7) as? UILabel!
		_gpaTypeLabel = nibView.viewWithTag(8) as? UILabel!
	}
	
	func setUIElements()
	{
		_creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
		_creditsLabel.text = String(_currentUser!._credits!)
		_spicesLabel.text =  _currentUser!._spices!._currentSpices + " " + NSLocalizedString("spices", comment: "")
		_logLabel.text = "Log : " + String(_currentUser!._log!._timeActive)
		_logLabel.textColor = _currentUser?._log?.getColor()
		
		
		let singleTap = UITapGestureRecognizer(target: self, action:#selector(ProfileViewController.gpaTapDetected(_:)))
		singleTap.numberOfTapsRequired = 1
		_gpaLabel.userInteractionEnabled = true
		_gpaLabel.addGestureRecognizer(singleTap)
		
		let gpa = _currentUser?.getLatestGPA()
		_gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		_gpaLabel.text = gpa?._value
		_gpaTypeLabel.text = gpa?._cycle
		
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var res = 0
		
		if (_flags == nil || _files == nil) { return 0 }
		
		if (section == 0)
		{
			if (_files?.count == 0)
			{
				res = 1
			}
			else { res = (_files?.count)! }
		}
		else {
			if ((_flags![section - 1]._modules.count) == 0)
			{
				res = 1
			}
			else { res = (_flags![section - 1]._modules.count) }
		}
		
		return res
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		
		if (indexPath.section == 0 && _files?.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = _files![indexPath.row]._title!
			cell.accessoryType = .DisclosureIndicator
		}
		else if (indexPath.section == 0 && _files?.count == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("emptyCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoFile", comment: "")
		}
		else if (_flags![indexPath.section - 1]._modules.count > 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("flagCell")!
			let titleLabel = cell.viewWithTag(1) as! UILabel
			let gradeLabel = cell.viewWithTag(2) as! UILabel
			let module = _flags![indexPath.section - 1]._modules[indexPath.row]
			titleLabel.text = module._title
			gradeLabel.text = module._grade
		}
		else if (indexPath.section > 0 && _flags![indexPath.section - 1]._modules.count == 0) {
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
		
		if (indexPath.section == 0)
		{
			_webViewData = _files![indexPath.row]
			self.performSegueWithIdentifier("webViewSegue", sender: self)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "webViewSegue") {
			let vc :WebViewViewController = segue.destinationViewController as! WebViewViewController
			vc._file = _webViewData!
			vc._isUrl = true
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (confettiView.isActive()) {
			confettiView.stopConfetti()
			confettiView.removeFromSuperview()
		}
	}
}
