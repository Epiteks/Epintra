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
	
	@IBOutlet weak var _profileViewContainer: UIView!
	
	var _profileImageView :UIImageView!
	var _creditsTitleLabel :UILabel!
	var _creditsLabel :UILabel!
	var _spicesLabel :UILabel!
	var _logLabel :UILabel!
	var _gpaTitleLabel :UILabel!
	var _gpaLabel :UILabel!
	var	_gpaTypeLabel :UILabel!
	var _currentUser :User?
	
	var _isModuleDownloading :Bool?
	var _isMarksDownloading :Bool?
	var _isFlagsDownloading :Bool?
	
	var _flags :[Flags]?
	
	@IBOutlet weak var _tableView: UITableView!
	@IBOutlet weak var _segmentedControl: UISegmentedControl!
	
	@IBOutlet weak var _actionButton: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		_segmentedControl.setTitle(NSLocalizedString("Modules", comment: ""), forSegmentAtIndex: 0)
		_segmentedControl.setTitle(NSLocalizedString("Marks", comment: ""), forSegmentAtIndex: 1)
		_segmentedControl.setTitle(NSLocalizedString("Flags", comment: ""), forSegmentAtIndex: 2)
		loadProfileView()
		setUIElements()
		self.title = _currentUser?._login
		
		self._segmentedControl.tintColor = UIUtils.backgroundColor()
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(OtherUserViewController.backButtonAction(_:))))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil
	}
	
	override func viewWillAppear(animated: Bool) {
		_isMarksDownloading = true
		MarksApiCalls.getMarksFor(user: self._currentUser!._login!) { (isOk :Bool, resp :[Mark]?, mess :String) in
			self._isMarksDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			}
			else {
				self._currentUser?._marks = resp
				if (self._segmentedControl.selectedSegmentIndex == 1) {
					MJProgressView.instance.hideProgress()
					self._tableView.reloadData()
				}
			}
		}
		self._isModuleDownloading = true
		ModulesApiCalls.getRegisteredModulesFor(user: self._currentUser!._login!) { (isOk :Bool, resp :[Module]?, mess :String) in
			self._isModuleDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			}
			else {
				self._currentUser?._modules = resp!
				if (self._segmentedControl.selectedSegmentIndex == 0) {
					MJProgressView.instance.hideProgress()
					self._tableView.reloadData()
				}
			}
		}
		self._isFlagsDownloading = true
		UserApiCalls.getUserFlags(self._currentUser!._login!) { (isOk :Bool, resp :[Flags]?, mess :String) in
			self._isFlagsDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._flags = resp!
				if (self._segmentedControl.selectedSegmentIndex == 2) {
					MJProgressView.instance.hideProgress()
					self._tableView.reloadData()
				}
			}
		}
	}
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	
	override func viewDidAppear(animated: Bool) {
		MJProgressView.instance.showProgress(self._tableView, white: false)
		self._profileImageView.image = UIImage(named: "userProfile")
		ImageDownloader.downloadFrom(link: (_currentUser?._imageUrl)!) {
			if let img = ApplicationManager.sharedInstance._downloadedImages![self._currentUser!._imageUrl!] {
				self._profileImageView.image = img
				self._profileImageView.cropToSquare()
			}
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		_profileImageView.cropToSquare()
		_profileImageView.toCircle()
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
		
		if (sender.selectedSegmentIndex == 0 && self._isModuleDownloading == true) {
			MJProgressView.instance.showProgress(self._tableView, white: false)
		}
		else if (sender.selectedSegmentIndex == 1 && self._isMarksDownloading == true) {
			MJProgressView.instance.showProgress(self._tableView, white: false)
		}
		else if (sender.selectedSegmentIndex == 2 && self._isFlagsDownloading == true) {
			MJProgressView.instance.showProgress(self._tableView, white: false)
		}
		else {
			MJProgressView.instance.hideProgress()
		}
		
		self._tableView.reloadData()
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (_segmentedControl.selectedSegmentIndex == 2) {
			return (_flags?.count)!
		}
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if ((_currentUser?._modules == nil && _segmentedControl.selectedSegmentIndex == 0)
			|| (_currentUser?._marks == nil && _segmentedControl.selectedSegmentIndex == 1)
			|| (_flags == nil && _segmentedControl.selectedSegmentIndex == 2)) {
				self._tableView.separatorStyle = .None
				return 0
		}
		self._tableView.separatorStyle = .SingleLine
		switch (_segmentedControl.selectedSegmentIndex)
		{
		case 0:
			return (_currentUser?._modules?.count)!
		case 1:
			return (_currentUser?._marks?.count)!
		case 2:
			let cnt = _flags![section]._modules.count
			return (cnt == 0 ? 1 : cnt)
		default:
			return 0
		}
		
		//		return (_segmentedControl.selectedSegmentIndex == 0 ? _currentUser?._modules!.count : _currentUser?._marks!.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
		
		if (_segmentedControl.selectedSegmentIndex == 0) {
			cell = tableView.dequeueReusableCellWithIdentifier("moduleCell")
			
			let titleLabel = cell?.viewWithTag(1) as! UILabel
			let creditsLabel = cell?.viewWithTag(2) as! UILabel
			let gradeLabel = cell?.viewWithTag(3) as! UILabel
			
			let module = _currentUser?._modules![indexPath.row]
			
			creditsLabel.text = NSLocalizedString("AvailableCredits", comment: "") + module!._credits!
			if (module!._grade != nil) {
				gradeLabel.text = module!._grade!
			}
			titleLabel.text = module!._title!
		}
		else if (_segmentedControl.selectedSegmentIndex == 1) {
			
			cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
			
			let actiTitle = cell?.viewWithTag(1) as! UILabel
			let moduleTitle = cell?.viewWithTag(2) as! UILabel
			let markLabel = cell?.viewWithTag(3) as! UILabel
			
			let mark = _currentUser?._marks![indexPath.row]
			
			actiTitle.text = mark?._title!
			moduleTitle.text = mark?._titleModule!
			markLabel.text = mark?._finalNote!
		}
		else {
			if (_flags![indexPath.section]._modules.count > 0) {
				cell = tableView.dequeueReusableCellWithIdentifier("flagCell")!
				let titleLabel = cell!.viewWithTag(1) as! UILabel
				let gradeLabel = cell!.viewWithTag(2) as! UILabel
				let module = _flags![indexPath.section]._modules[indexPath.row]
				titleLabel.text = module._title
				gradeLabel.text = module._grade
			}
			else if (indexPath.section > 0 && _flags![indexPath.section]._modules.count == 0) {
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
		
		if (_currentUser?._phone != nil && _currentUser?._phone?.characters.count > 0) {
			
			let callAction = UIAlertAction(title: NSLocalizedString("Call", comment: "") + " " + (_currentUser?._phone!)!, style: .Default) { (action) in
				
				let nbr = self._currentUser?._phone!.stringByReplacingOccurrencesOfString(" ", withString: "")
				
				let numberToCall = "tel://" + nbr!
				UIApplication.sharedApplication().openURL(NSURL(string: numberToCall)!)
			}
			alertController.addAction(callAction)
		}
		
		let emailAction = UIAlertAction(title: NSLocalizedString("Email", comment: ""), style: .Default) { (action) in
			
			if (MFMailComposeViewController.canSendMail()) {
				let mailComposerVC = MFMailComposeViewController()
				mailComposerVC.mailComposeDelegate = self
				mailComposerVC.setToRecipients([(self._currentUser?._internalEmail!)!])
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
		
		if (_segmentedControl.selectedSegmentIndex != 2)
		{
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
