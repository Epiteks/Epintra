//
//  ProjectsDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
	
	@IBOutlet weak var masterImage: UIImageView!
	@IBOutlet weak var masterName: UILabel!
	@IBOutlet weak var projectEnd: UILabel!
	@IBOutlet weak var projectProgressView: UIProgressView!
	
	var project : ProjectDetail?
	
	var members = [User]()
	var files = [File]()
	
	var webViewData : File?
	
	var marksData : [Mark]?
	
	var marksAllowed = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		projectEnd.text = project?.endActi?.toDate().toProjectEnding()
		
		self.title = project?.actiTitle
		
		files = (project?.files)!
		
		if (project?.isRegistered() == true) {
			let grp = project?.findGroup((project?.userProjectCode!)!)
			members = (grp?.members)!
			masterName.text = grp?.master?.title
			setUIIfRegistered(grp)
		} else {
			masterName.text = NSLocalizedString("NotRegisteredProject", comment: "")
			if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl)!] {
				self.masterImage.image = img
				self.masterImage.cropToSquare()
			}
		}
		
		self.masterImage.cropToSquare()
		self.masterImage.toCircle()
		fillProgressView()
	}
	
	func setUIIfRegistered(grp :ProjectGroup?) {
		
		if let img = ApplicationManager.sharedInstance.downloadedImages![(grp?.master?.imageUrl)!] {
			self.masterImage.image = img
			self.masterImage.cropToSquare()
		} else {
			ImageDownloader.downloadFrom(link: (grp?.master?.imageUrl)!) {
				if let img = ApplicationManager.sharedInstance.downloadedImages![(grp?.master?.imageUrl)!] {
					self.masterImage.image = img
					self.masterImage.cropToSquare()
					self.masterImage.toCircle()
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func fillProgressView() {
		
		let begin = self.project?.beginActi?.toDate()
		let end = self.project?.endActi?.toDate()
		let today = NSDate()
		
		let totalTime = end?.timeIntervalSinceDate(begin!)
		let currentTime = end?.timeIntervalSinceDate(today)
		
		let percent = 1 - (currentTime! * 100 / totalTime!) / 100
		
		if (end?.earlierDate(today) == end) {
			self.projectProgressView.setProgress(1.0, animated: true)
			self.projectProgressView.progressTintColor = UIUtils.planningRedColor()
			return
		}
		
		self.projectProgressView.setProgress(Float(percent), animated: true)
		
		if (percent > 0.8) {
			self.projectProgressView.progressTintColor = UIUtils.planningOrangeColor()
		} else {
			self.projectProgressView.progressTintColor = UIUtils.planningGreenColor()
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
			return files.count
		}
		return members.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("userCell")!
		
		if (indexPath.section == 0) {
			
			cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
			
			let titleLabel = cell.viewWithTag(1) as! UILabel
			
			titleLabel.text = files[indexPath.row].title!
			
			cell.accessoryType = .DisclosureIndicator
			
		} else if (indexPath.section == 1) {
			cell = tableView.dequeueReusableCellWithIdentifier("userCell")!
			
			let imgView = cell.viewWithTag(1) as! UIImageView
			let userLabel = cell.viewWithTag(2) as! UILabel
			let statusImgView = cell.viewWithTag(3) as!UIImageView
			
			imgView.image = UIImage(named: "userProfile")
			
			let usr = members[indexPath.row]
			
			userLabel.text = usr.title
			
			cell.tag = indexPath.row + 100
			
			if (usr.status == "confirmed") {
				statusImgView.image = UIImage(named: "Done")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
				statusImgView.tintColor = UIUtils.planningGreenColor()
			} else {
				statusImgView.image = UIImage(named: "Delete")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
				statusImgView.tintColor = UIUtils.planningRedColor()
			}
			
			if let img = ApplicationManager.sharedInstance.downloadedImages![usr.imageUrl!] {
				if (cell.tag == (indexPath.row + 100)) {
					imgView.image = img
				}
			} else {
				ImageDownloader.downloadFrom(link: usr.imageUrl!) {
					if let img = ApplicationManager.sharedInstance.downloadedImages![usr.imageUrl!] {
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
		if (section == 0) {
			return NSLocalizedString("Files", comment: "")
		}
		return NSLocalizedString("Members", comment: "")
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (indexPath.section == 0) {
			webViewData = files[indexPath.row]
			self.performSegueWithIdentifier("webViewSegue", sender: self)
		}
	}
	
	//	@IBAction func allMarksButtonPressed(sender :AnyObject) {
	//		
	//		MarksApiCalls.getProjectMarksForProject(self.project!) { (isOk :Bool, resp :[Mark]?, mess :String) in
	//			
	//			if (!isOk) {
	//				ErrorViewer.errorPresent(self, mess: mess) {}
	//			}
	//			else {
	//				self.marksData = resp!
	//				self.performSegueWithIdentifier("allMarksSegue", sender: self)
	//			}
	//		}
	//		
	//	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "webViewSegue") {
			let vc :WebViewViewController = segue.destinationViewController as! WebViewViewController
			vc.file = webViewData!
			vc.isUrl = true
		} else if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc.marks = marksData
		}
		
	}
}
