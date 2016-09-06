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
	
	@IBOutlet weak var tableView: UITableView!
	
	var currentUser :User?
	
	var files :[File]?
	var flags :[Flags]?
	var webViewData :File?
	
	var downloadingFiles: Bool = false
	var downloadingFlags: Bool = false
	
	let sectionsTitles = [
		"",
		"Files",
		"Medals",
		"Remarkables",
		"Difficulty",
		"Ghost"
	]
	
	override func viewDidLoad() {
		
		currentUser = ApplicationManager.sharedInstance.user
		
		calls()
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Profile", comment: "")
	}
	
	/*!
	All needed calls
	*/
	func calls() {
		self.callFlags()
		self.callDocuments()
	}
	
	/*!
	Fetch all flags of current user and update tableview
	*/
	func callFlags() {
		
		self.downloadingFlags = true
		
		userRequests.getUserFlags("junger_m") { (result) in
			switch (result) {
			case .Success(let data):
				if let flgs = data as? [Flags] {
					self.flags = flgs
				}
				logger.info("User flags fetched")
				break
			case .Failure(let error):
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				break
			}
			self.downloadingFlags = false
			self.tableView.reloadData()
		}
	}
	
	/*!
	Fetch all documents of current user and update tableview
	*/
	func callDocuments() {
		
		self.downloadingFiles = true
		
		userRequests.getUserDocuments() { (result) in
			switch (result) {
			case .Success(let data):
				if let documents = data as? [File] {
					self.files = documents
				}
				logger.info("User documents fetched")
				break
			case .Failure(let error):
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				break
			}
			self.downloadingFiles = false
			self.tableView.reloadData()
			
		}
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 6
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var res = 0
		
		switch section {
		case 0: // User informations
			res = 1
			break
		case 1: // Documents
			if files == nil || files?.count == 0 {
				res = 1
			} else {
				res = (files?.count)!
			}
			break
		default: // Other sections for flags
			if (flags == nil || flags![section - 2].modules.count == 0) {
				res = 1
			} else {
				res = (flags![section - 2].modules.count)
			}
		}
		return res
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		
		if indexPath.section == 0 { // Profile Cell, the first one
			cell = tableView.dequeueReusableCellWithIdentifier("profileCell")! as! ProfileTableViewCell
		} else if indexPath.section == 1 { // Files
			cell = cellFiles(indexPath.row)
		} else { // Flags
			cell = cellFlag(indexPath)
		}
		
		return cell
	}
	
	/*!
	Returns the cell for file data
	
	- parameter index:	row index
	
	- returns: cell
	*/
	func cellFiles(index: Int) -> UITableViewCell {
		
		if self.downloadingFiles == true {
			return cellLoading()
		}
		
		if self.files == nil || self.files?.count <= 0 {
			return cellEmpty(data: "NoFile")
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
		
		let titleLabel = cell.viewWithTag(1) as! UILabel
		titleLabel.text = files![index].title!
		cell.accessoryType = .DisclosureIndicator
		
		return cell
	}
	
	/*!
	Returns the cell for flag data
	
	- parameter indexPath:	index
	
	- returns: cell
	*/
	func cellFlag(indexPath: NSIndexPath) -> UITableViewCell {
		
		let cellIdentifier = "flagCell"
		
		if self.downloadingFlags == true {
			return cellLoading()
		}
		
		if self.flags == nil || self.flags?.count <= 0 || self.flags![indexPath.section - 2].modules.count <= 0 {
			return cellEmpty(data: "NoFlag")
		}
		
		var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? FlagTableViewCell
		
		if cell == nil {
			let nib = UINib(nibName: "FlagTableViewCell", bundle:nil)
			tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? FlagTableViewCell
		}
		
		let module = flags![indexPath.section - 2].modules[indexPath.row]
		
		cell?.moduleLabel.text = module.title
		cell?.gradeLabel.text = module.grade
		
		return cell!
	}
	
	/*!
	Returns the cell for empty data
	
	- parameter str:	data type
	
	- returns: cell
	*/
	func cellEmpty(data str: String) -> UITableViewCell {
		
		let cellIdentifier = "emptyCell"
		
		var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? EmptyDataTableViewCell
		
		if cell == nil {
			let nib = UINib(nibName: "EmptyDataTableViewCell", bundle:nil)
			tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? EmptyDataTableViewCell
		}
		
		cell?.infoLabel.text = NSLocalizedString(str, comment: "")
		
		return cell!
	}
	
	/*!
	Returns the cell for loading data
	
	- returns: cell
	*/
	func cellLoading() -> UITableViewCell {
		
		let cellIdentifier = "loadingDataCell"
		
		var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
		
		if cell == nil {
			let nib = UINib(nibName: "LoadingDataTableViewCell", bundle:nil)
			tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		
		return cell!
	}
	
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 110
		} else {
			return 44
		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return NSLocalizedString(sectionsTitles[section], comment: "")
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
}
