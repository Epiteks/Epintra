//
//  SearchUserViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {
	
	var users = [StudentInfo]()
	var filteredData = [StudentInfo]()
	
	var selectedUser :User?
	
	var resultSearchController:UISearchController!
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var downloadingView :UIView!
	@IBOutlet weak var downloadingLabel :UILabel!
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// Do any additional setup after loading the view.
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
		resultSearchController.searchBar.sizeToFit()
		//self.tableView.tableHeaderView = resultSearchController.searchBar
		
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.whiteColor()
		resultSearchController.searchBar.backgroundColor = UIUtils.backgroundColor()
		
		self.title = NSLocalizedString("Search", comment: "")
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		let dbManager = DBManager.getInstance()
		downloadingLabel.text = NSLocalizedString("DownloadingAllUsers", comment :"")
		users = dbManager.getAllStudentData() as AnyObject as! [StudentInfo]
		
		if (users.count == 0) {
			showConfirmationAlert()
			//			self.downloadingView.hidden = false
			//			MJProgressView.instance.showProgress(self.view, white: true)
			//			UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
			//				
			//				self.users = dbManager.getAllStudentData() as AnyObject as! [StudentInfo]
			//				MJProgressView.instance.hideProgress()
			//				self.navigationItem.titleView = self.resultSearchController.searchBar
			//				self.tableView.reloadData()
			//				self.downloadingView.hidden = true
			//			}
		} else {
			self.downloadingView.hidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(SearchUserViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		
		self.tableView.addSubview(refreshControl)
		
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel) { (action:UIAlertAction!) in
			self.refreshControl.endRefreshing()
			self.downloadingView.hidden = true
			self.tableView.scrollEnabled = true
			self.tableView.userInteractionEnabled = true
			if (self.users.count == 0) {
				self.navigationController?.popViewControllerAnimated(true)
			}
		}
		alertController.addAction(cancelAction)
		
		let OKAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { (action:UIAlertAction!) in
			self.refreshControl.endRefreshing()
			let db = DBManager.getInstance()
			self.downloadingView.hidden = false
			MJProgressView.instance.showProgress(self.view, white: true)
			UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
				self.users = db.getAllStudentData() as AnyObject as! [StudentInfo]
				self.refreshControl.endRefreshing()
				MJProgressView.instance.hideProgress()
				self.downloadingView.hidden = true
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self.tableView.reloadData()
				self.tableView.userInteractionEnabled = true
				self.tableView.scrollEnabled = true
			}
		}
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true, completion:nil)
	}
	
	
	func refreshData(sender:AnyObject) {
		self.tableView.userInteractionEnabled = false
		self.tableView.scrollEnabled = false
		showConfirmationAlert()
		//		let db = DBManager.getInstance()
		//		UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
		//			self.users = db.getAllStudentData() as AnyObject as! [StudentInfo]
		//			self.refreshControl.endRefreshing()
		//			self.navigationItem.titleView = self.resultSearchController.searchBar
		//			self.tableView.reloadData()
		//			self.tableView.userInteractionEnabled = true
		//			self.tableView.scrollEnabled = true
		//		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		tableView.userInteractionEnabled = true
		tableView.scrollEnabled = true
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.active) {
			return filteredData.count
		}
		return users.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell;
		
		let cell = tableView.dequeueReusableCellWithIdentifier("userCell")
		
		let loginTitle = cell?.viewWithTag(1) as! UILabel
		let promo = cell?.viewWithTag(2) as! UILabel
		let city = cell?.viewWithTag(3) as! UILabel
		
		if(resultSearchController.active) {
			loginTitle.text = filteredData[indexPath.row].login
			promo.text = NSLocalizedString(String(filteredData[indexPath.row].promo!), comment: "")
			city.text = filteredData[indexPath.row].city
		} else {
			loginTitle.text = users[indexPath.row].login
			promo.text = NSLocalizedString(String(users[indexPath.row].promo!), comment: "")
			city.text = users[indexPath.row].city
		}
		
		return cell!
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
			filteredData.removeAll(keepCapacity: false)
			let array = users.filter() { ($0.login?.containsString(searchController.searchBar.text!.lowercaseString))! }
			filteredData = array
			tableView.reloadData()
			
		} else {
			
			filteredData.removeAll(keepCapacity: false)
			
			filteredData = users
			
			tableView.reloadData()
			
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		resultSearchController.active = false
		if (segue.identifier == "otherUserProfileSegue") {
			let vc = segue.destinationViewController as! OtherUserViewController
			vc.currentUser = selectedUser
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.view.endEditing(true)
		let usr = (self.resultSearchController.active == true ? filteredData[indexPath.row] : users[indexPath.row])
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		MJProgressView.instance.showProgress(self.view, white: false)
		UserApiCalls.getSelectedUserData(usr.login!) { (isOk :Bool, resp :User?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
				tableView.userInteractionEnabled = false
				tableView.scrollEnabled = false
			} else {
				self.selectedUser = resp
				print(self.selectedUser?.login)
				MJProgressView.instance.hideProgress()
				self.performSegueWithIdentifier("otherUserProfileSegue", sender: self)
				
				//				MarksApiCalls.getMarksFor(user: self.selectedUser!.login!) { (isOk :Bool, resp :[Mark]?, mess :String) in
				//					
				//					if (!isOk) {
				//						ErrorViewer.errorPresent(self, mess: mess) {}
				//						MJProgressView.instance.hideProgress()
				//						tableView.userInteractionEnabled = false
				//						tableView.scrollEnabled = false
				//					}
				//					else {
				//						self.selectedUser?.marks = resp
				//						
				//						ModulesApiCalls.getRegisteredModulesFor(user: self.selectedUser!.login!) { (isOk :Bool, resp :[Module]?, mess :String) in
				//							if (!isOk) {
				//								ErrorViewer.errorPresent(self, mess: mess) {}
				//								MJProgressView.instance.hideProgress()
				//								tableView.userInteractionEnabled = false
				//								tableView.scrollEnabled = false
				//							}
				//							else {
				//								self.selectedUser?.modules = resp!
				//								MJProgressView.instance.hideProgress()
				//								self.performSegueWithIdentifier("otherUserProfileSegue", sender: self)		
				//							}
				//							
				//						}
				//						
				//						
				//					}
			}
		}
		
	}
	
}
