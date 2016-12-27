//
//  ProfileViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

fileprivate func < <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	var currentUser: User?
	
	var files: [File]?
	var flags: [Flags]?
	var webViewData: File?
	
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
		
		// TODO REMOVE THIS SHIT
		userRequests.getUserFlags(ApplicationManager.sharedInstance.currentLogin!) { (result) in
			switch (result) {
			case .success(let data):
				if let flgs = data as? [Flags] {
					self.flags = flgs
				}
				log.info("User flags fetched")
				break
			case .failure(let error):
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) { }
				}
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
			case .success(let data):
				if let documents = data as? [File] {
					self.files = documents
				}
				log.info("User documents fetched")
				break
			case .failure(let error):
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) { }
				}
				break
			}
			self.downloadingFiles = false
			self.tableView.reloadData()
			
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 6
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
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
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = UITableViewCell()
		
		if (indexPath as NSIndexPath).section == 0 { // Profile Cell, the first one
			cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")!
			let profileView = cell.viewWithTag(1) as! ProfileView
			profileView.setUserData(currentUser!)
			
			if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl!)!] {
				profileView.setUserImage(img)
			}
		} else if (indexPath as NSIndexPath).section == 1 { // Files
			cell = cellFiles((indexPath as NSIndexPath).row)
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
	func cellFiles(_ index: Int) -> UITableViewCell {
		
		if self.downloadingFiles == true {
			return cellLoading()
		}
		
		if self.files == nil || self.files?.count <= 0 {
			return cellEmpty(data: "NoFile")
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell")!
		
		let titleLabel = cell.viewWithTag(1) as! UILabel
		titleLabel.text = files![index].title!
		cell.accessoryType = .disclosureIndicator
		
		return cell
	}
	
	/*!
	Returns the cell for flag data
	
	- parameter indexPath:	index
	
	- returns: cell
	*/
	func cellFlag(_ indexPath: IndexPath) -> UITableViewCell {
		
		let cellIdentifier = "flagCell"
		
		if self.downloadingFlags == true {
			return cellLoading()
		}
		
		if self.flags == nil || self.flags?.count <= 0 || self.flags![(indexPath as NSIndexPath).section - 2].modules.count <= 0 {
			return cellEmpty(data: "NoFlag")
		}
		
		var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FlagTableViewCell
		
		if cell == nil {
			let nib = UINib(nibName: "FlagTableViewCell", bundle:nil)
			tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FlagTableViewCell
		}
		
		let module = flags![(indexPath as NSIndexPath).section - 2].modules[(indexPath as NSIndexPath).row]
		
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
		
		var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? EmptyDataTableViewCell
		
		if cell == nil {
			let nib = UINib(nibName: "EmptyDataTableViewCell", bundle:nil)
			tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? EmptyDataTableViewCell
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
		
		var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
		
		if cell == nil {
			let nib = UINib(nibName: "LoadingDataTableViewCell", bundle:nil)
			tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
			cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath as NSIndexPath).section == 0 {
			return 110
		} else {
			return 44
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return NSLocalizedString(sectionsTitles[section], comment: "")
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if ((indexPath as NSIndexPath).section == 1) {
			webViewData = files![(indexPath as NSIndexPath).row]
			self.performSegue(withIdentifier: "webViewSegue", sender: self)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "webViewSegue") {
			let vc: WebViewViewController = segue.destination as! WebViewViewController
			vc.file = webViewData!
			//vc.isUrl = true
		}
	}
}
