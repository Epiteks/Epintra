//
//  SearchUserViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {
	
	var _users = [StudentInfo]()
	var _filteredData = [StudentInfo]()
	
	var _selectedUser :User?
	
	var resultSearchController:UISearchController!
	
	@IBOutlet weak var _tableView: UITableView!
	
	@IBOutlet weak var _downloadingView :UIView!
	@IBOutlet weak var _downloadingLabel :UILabel!
	
	var _refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// Do any additional setup after loading the view.
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
		resultSearchController.searchBar.sizeToFit()
		//self._tableView.tableHeaderView = resultSearchController.searchBar
		
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.whiteColor()
		resultSearchController.searchBar.backgroundColor = UIUtils.backgroundColor()
		
		self.title = NSLocalizedString("Search", comment: "")
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: ("backButtonAction:"))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil
		//self.navigationItem.titleView = resultSearchController.searchBar
		
		let dbManager = DBManager.getInstance()
		_downloadingLabel.text = NSLocalizedString("DownloadingAllUsers", comment :"")
		_users = dbManager.getAllStudentData() as AnyObject as! [StudentInfo]
		
		if (_users.count == 0) {
			showConfirmationAlert()
			//			self._downloadingView.hidden = false
			//			MJProgressView.instance.showProgress(self.view, white: true)
			//			UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
			//				
			//				self._users = dbManager.getAllStudentData() as AnyObject as! [StudentInfo]
			//				MJProgressView.instance.hideProgress()
			//				self.navigationItem.titleView = self.resultSearchController.searchBar
			//				self._tableView.reloadData()
			//				self._downloadingView.hidden = true
			//			}
		}
		else {
			self._downloadingView.hidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: "refreshData:", forControlEvents: .ValueChanged)
		
		self._tableView.addSubview(_refreshControl)
		
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel) { (action:UIAlertAction!) in
			self._refreshControl.endRefreshing()
			self._downloadingView.hidden = true
			self._tableView.scrollEnabled = true
			self._tableView.userInteractionEnabled = true
			if (self._users.count == 0) {
				self.navigationController?.popViewControllerAnimated(true)
			}
		}
		alertController.addAction(cancelAction)
		
		let OKAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { (action:UIAlertAction!) in
			self._refreshControl.endRefreshing()
			let db = DBManager.getInstance()
			self._downloadingView.hidden = false
			MJProgressView.instance.showProgress(self.view, white: true)
			UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
				self._users = db.getAllStudentData() as AnyObject as! [StudentInfo]
				self._refreshControl.endRefreshing()
				MJProgressView.instance.hideProgress()
				self._downloadingView.hidden = true
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self._tableView.reloadData()
				self._tableView.userInteractionEnabled = true
				self._tableView.scrollEnabled = true
			}
		}
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true, completion:nil)
	}
	
	
	func refreshData(sender:AnyObject)
	{
		self._tableView.userInteractionEnabled = false
		self._tableView.scrollEnabled = false
		showConfirmationAlert()
		//		let db = DBManager.getInstance()
		//		UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
		//			self._users = db.getAllStudentData() as AnyObject as! [StudentInfo]
		//			self._refreshControl.endRefreshing()
		//			self.navigationItem.titleView = self.resultSearchController.searchBar
		//			self._tableView.reloadData()
		//			self._tableView.userInteractionEnabled = true
		//			self._tableView.scrollEnabled = true
		//		}
		
	}
	
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		_tableView.userInteractionEnabled = true
		_tableView.scrollEnabled = true
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.active) {
			return _filteredData.count
		}
		return _users.count;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell;
		
		let cell = tableView.dequeueReusableCellWithIdentifier("userCell")
		
		let loginTitle = cell?.viewWithTag(1) as! UILabel
		let promo = cell?.viewWithTag(2) as! UILabel
		let city = cell?.viewWithTag(3) as! UILabel
		
		if(resultSearchController.active){
			loginTitle.text = _filteredData[indexPath.row]._login
			promo.text = NSLocalizedString(String(_filteredData[indexPath.row]._promo!), comment: "")
			city.text = _filteredData[indexPath.row]._city
		} else {
			loginTitle.text = _users[indexPath.row]._login
			promo.text = NSLocalizedString(String(_users[indexPath.row]._promo!), comment: "")
			city.text = _users[indexPath.row]._city
		}
		
		return cell!
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
			_filteredData.removeAll(keepCapacity: false)
			let array = _users.filter() { ($0._login?.containsString(searchController.searchBar.text!.lowercaseString))! }
			_filteredData = array
			_tableView.reloadData()
			
		}
		else {
			
			_filteredData.removeAll(keepCapacity: false)
			
			_filteredData = _users
			
			_tableView.reloadData()
			
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		resultSearchController.active = false
		if (segue.identifier == "otherUserProfileSegue") {
			let vc = segue.destinationViewController as! OtherUserViewController
			vc._currentUser = _selectedUser
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.view.endEditing(true)
		let usr = (self.resultSearchController.active == true ? _filteredData[indexPath.row] : _users[indexPath.row])
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		MJProgressView.instance.showProgress(self.view, white: false)
		UserApiCalls.getSelectedUserData(usr._login!) { (isOk :Bool, resp :User?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
				tableView.userInteractionEnabled = false
				tableView.scrollEnabled = false
			}
			else {
				self._selectedUser = resp
				print(self._selectedUser?._login)
				MJProgressView.instance.hideProgress()
				self.performSegueWithIdentifier("otherUserProfileSegue", sender: self)
				
				//				MarksApiCalls.getMarksFor(user: self._selectedUser!._login!) { (isOk :Bool, resp :[Mark]?, mess :String) in
				//					
				//					if (!isOk) {
				//						ErrorViewer.errorPresent(self, mess: mess) {}
				//						MJProgressView.instance.hideProgress()
				//						tableView.userInteractionEnabled = false
				//						tableView.scrollEnabled = false
				//					}
				//					else {
				//						self._selectedUser?._marks = resp
				//						
				//						ModulesApiCalls.getRegisteredModulesFor(user: self._selectedUser!._login!) { (isOk :Bool, resp :[Module]?, mess :String) in
				//							if (!isOk) {
				//								ErrorViewer.errorPresent(self, mess: mess) {}
				//								MJProgressView.instance.hideProgress()
				//								tableView.userInteractionEnabled = false
				//								tableView.scrollEnabled = false
				//							}
				//							else {
				//								self._selectedUser?._modules = resp!
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


