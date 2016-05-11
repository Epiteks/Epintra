//
//  ProjectsDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
	
	@IBOutlet weak var _masterImage: UIImageView!
	@IBOutlet weak var _masterName: UILabel!
	@IBOutlet weak var _projectEnd: UILabel!
	@IBOutlet weak var _projectProgressView: UIProgressView!
	
	var _project : ProjectDetail?
	
	var _members = [User]()
	var _files = [File]()
	
	var _webViewData : File?
	
	var _marksData : [Mark]?
	
	var _marksAllowed = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		_projectEnd.text = _project?._endActi?.toDate().toProjectEnding()
		
		self.title = _project?._actiTitle
		
		_files = (_project?._files)!
		
		if (_project?.isRegistered() == true) {
			let grp = _project?.findGroup((_project?._userProjectCode!)!)
			_members = (grp?._members)!
			_masterName.text = grp?._master?._title
			setUIIfRegistered(grp)
		}
		else {
			_masterName.text = NSLocalizedString("NotRegisteredProject", comment: "")
			if let img = ApplicationManager.sharedInstance._downloadedImages![(ApplicationManager.sharedInstance._user?._imageUrl)!]
			{
				self._masterImage.image = img
				self._masterImage.cropToSquare()
			}
		}
		
		self._masterImage.cropToSquare()
		self._masterImage.toCircle()
		fillProgressView()
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: ("backButtonAction:"))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil
		
	}
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}

	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "ProjectDetails")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	func setUIIfRegistered(grp :ProjectGroup?) {
		
		if let img = ApplicationManager.sharedInstance._downloadedImages![(grp?._master?._imageUrl)!]
		{
			self._masterImage.image = img
			self._masterImage.cropToSquare()
		} else {
			ImageDownloader.downloadFrom(link: (grp?._master?._imageUrl)!) {
				if let img = ApplicationManager.sharedInstance._downloadedImages![(grp?._master?._imageUrl)!]
				{
					self._masterImage.image = img
					self._masterImage.cropToSquare()
					self._masterImage.toCircle()
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func fillProgressView() {
		
		let begin = self._project?._beginActi?.toDate()
		let end = self._project?._endActi?.toDate()
		let today = NSDate()
		
		let totalTime = end?.timeIntervalSinceDate(begin!)
		let currentTime = end?.timeIntervalSinceDate(today)
		
		let percent = 1 - (currentTime! * 100 / totalTime!) / 100
		
		if (end?.earlierDate(today) == end) {
			self._projectProgressView.setProgress(1.0, animated: true)
			self._projectProgressView.progressTintColor = UIUtils.planningRedColor()
			return
		}
		
		self._projectProgressView.setProgress(Float(percent), animated: true)
		
		if (percent > 0.8) {
			self._projectProgressView.progressTintColor = UIUtils.planningOrangeColor()
		}
		else {
			self._projectProgressView.progressTintColor = UIUtils.planningGreenColor()
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
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (section == 0) {
			return _files.count
		}
		return _members.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("userCell")!
		
		if (indexPath.section == 0) {
			
			cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
			
			let titleLabel = cell.viewWithTag(1) as! UILabel
			
			titleLabel.text = _files[indexPath.row]._title!
			
			cell.accessoryType = .DisclosureIndicator
			
		} else if (indexPath.section == 1) {
			cell = tableView.dequeueReusableCellWithIdentifier("userCell")!
			
			let imgView = cell.viewWithTag(1) as! UIImageView
			let userLabel = cell.viewWithTag(2) as! UILabel
			let statusImgView = cell.viewWithTag(3) as!UIImageView
			
			imgView.image = UIImage(named: "userProfile")
			
			let usr = _members[indexPath.row]
			
			userLabel.text = usr._title
			
			cell.tag = indexPath.row + 100
			
			if (usr._status == "confirmed") {
				statusImgView.image = UIImage(named: "Done")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
				statusImgView.tintColor = UIUtils.planningGreenColor()
			}
			else {
				statusImgView.image = UIImage(named: "Delete")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
				statusImgView.tintColor = UIUtils.planningRedColor()
			}
			
			if let img = ApplicationManager.sharedInstance._downloadedImages![usr._imageUrl!]
			{
				if (cell.tag == (indexPath.row + 100)) {
					imgView.image = img
				}
			}
			else {
				ImageDownloader.downloadFrom(link: usr._imageUrl!) {
					if let img = ApplicationManager.sharedInstance._downloadedImages![usr._imageUrl!]
					{
						if (cell.tag == (indexPath.row + 100)) {
							imgView.image = img
							
							imgView.cropToSquare()
							imgView.toCircle()
						}
					}
				}
			}
			imgView.cropToSquare()
			imgView.toCircle()
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (section == 0)
		{
			return NSLocalizedString("Files", comment: "")
		}
		return NSLocalizedString("Members", comment: "")
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (indexPath.section == 0) {
			_webViewData = _files[indexPath.row]
			self.performSegueWithIdentifier("webViewSegue", sender: self)
		}
	}
	
//	@IBAction func allMarksButtonPressed(sender :AnyObject) {
//		
//		MarksApiCalls.getProjectMarksForProject(self._project!) { (isOk :Bool, resp :[Mark]?, mess :String) in
//			
//			if (!isOk) {
//				ErrorViewer.errorPresent(self, mess: mess) {}
//			}
//			else {
//				self._marksData = resp!
//				self.performSegueWithIdentifier("allMarksSegue", sender: self)
//			}
//		}
//		
//	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "webViewSegue") {
			let vc :WebViewViewController = segue.destinationViewController as! WebViewViewController
			vc._file = _webViewData!
			vc._isUrl = true
		}
		else if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc._marks = _marksData
		}
		
	}
}
