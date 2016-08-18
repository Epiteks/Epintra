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
	@IBOutlet weak var _profileViewContainer: UIView!
	@IBOutlet weak var _alertTableView: UITableView!
	
	var _profileImageView :UIImageView!
	var _creditsTitleLabel :UILabel!
	var _creditsLabel :UILabel!
	var _spicesLabel :UILabel!
	var _logLabel :UILabel!
	var _gpaTitleLabel :UILabel!
	var _gpaLabel :UILabel!
	var	_gpaTypeLabel :UILabel!
	var _currentUser :User?
	
	var _refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_currentUser = ApplicationManager.sharedInstance._user!
		
		loadProfileView()
		
		if let img = ApplicationManager.sharedInstance._downloadedImages![(ApplicationManager.sharedInstance._user?._imageUrl!)!]
		{
			self._profileImageView.image = img
			self._profileImageView.cropToSquare()
		}
		
		_profileImageView.toCircle()
		_profileImageView.cropToSquare()
		
		setUIElements()
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: #selector(HomeViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self._alertTableView.addSubview(_refreshControl)
		
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Notifications", comment: "")
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Home")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	override func viewDidAppear(animated: Bool) {
		
		let app = ApplicationManager.sharedInstance
		
		if (NSDate().timeIntervalSince1970 > ((5 * 60 * 1000) + app._lastUserApiCall!)) {
			refreshData(self)
		}
	}
	
	func refreshData(sender:AnyObject)
	{
		
		UserApiCalls.getUserData(ApplicationManager.sharedInstance._currentLogin!) { (isOk :Bool, s :String) in
		 
			if (!isOk) {
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: s) {}
				self._refreshControl.endRefreshing()
				self._alertTableView.reloadData()
			}
			else {
				ImageDownloader.downloadFrom(link: (ApplicationManager.sharedInstance._user?._imageUrl!)!) {
					UserApiCalls.getUserHistory() { (isOk :Bool, s :String) in
						MJProgressView.instance.hideProgress()
						if (!isOk) {
							ErrorViewer.errorPresent(self, mess: s) {}
						}
						self._refreshControl.endRefreshing()
						self._alertTableView.reloadData()
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
		
		
		let gpa = _currentUser?.getLatestGPA()
		_gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		_gpaLabel.text = gpa?._value
		_gpaTypeLabel.text = gpa?._cycle
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
		
		let rows = _currentUser?._history?.count
		
		if (rows == 0) {
			let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
			
			messageLabel.text =  NSLocalizedString("NoAlerts", comment: "")
			messageLabel.textColor = UIColor.blackColor()
			messageLabel.numberOfLines = 0;
			messageLabel.textAlignment = .Center;
			messageLabel.font = UIFont.systemFontOfSize(13)
			messageLabel.sizeToFit()
			
			_alertTableView.backgroundView = messageLabel;
			_alertTableView.separatorStyle = UITableViewCellSeparatorStyle.None
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
		
		let history = _currentUser?._history![indexPath.row]
		
		profileImage.image = UIImage(named: "userProfile")
		
		if (history!._userPicture!.characters.count > 0) {
			if let img = ApplicationManager.sharedInstance._downloadedImages![history!._userPicture!]
			{
				if (cell.tag == (indexPath.row + 100)) {
					profileImage.image = img
				}
			}
			else {
				ImageDownloader.downloadFrom(link: history!._userPicture!) {
					if let img = ApplicationManager.sharedInstance._downloadedImages![history!._userPicture!]
					{
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
		
		content.text = history?._title!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
		
		date.text = (history?._userName!)! + " - " +  (history?._date!.toAlertString())!
		
		return cell
	}
}
