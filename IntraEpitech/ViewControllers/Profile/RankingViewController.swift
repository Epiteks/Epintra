//
//  RankingViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {
	
	@IBOutlet weak var _promoSelection: UISegmentedControl!
	@IBOutlet weak var _tableView :UITableView!
	@IBOutlet weak var _downloadingView :UIView!
	@IBOutlet weak var _downloadingLabel :UILabel!
	
	var _students = [StudentInfo]()
	var _filteredData = [StudentInfo]()
	
	var _teks = ["tech1", "tech2", "tech3", "tech4", "tech5"]
	
	var resultSearchController:UISearchController!
	
	var _refreshControl = UIRefreshControl()
	
	var _selectedUser :User?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = NSLocalizedString("Ranking", comment: "")
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: ("backButtonAction:"))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil
		let db = DBManager.getInstance()
		
		_promoSelection.setTitle(NSLocalizedString(_teks[0], comment: ""), forSegmentAtIndex: 0)
		_promoSelection.setTitle(NSLocalizedString(_teks[1], comment: ""), forSegmentAtIndex: 1)
		_promoSelection.setTitle(NSLocalizedString(_teks[2], comment: ""), forSegmentAtIndex: 2)
		_promoSelection.setTitle(NSLocalizedString(_teks[3], comment: ""), forSegmentAtIndex: 3)
		_promoSelection.setTitle(NSLocalizedString(_teks[4], comment: ""), forSegmentAtIndex: 4)
		_promoSelection.tintColor = UIUtils.backgroundColor()
		
		_downloadingLabel.text = NSLocalizedString("DownloadingAllUsers", comment :"")
		
		_students = db.getStudentDataFor(Promo: _teks[_promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
		resultSearchController.searchBar.sizeToFit()
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.whiteColor()
		
		if (_students.count == 0) {
			showConfirmationAlert()
			//            self._downloadingView.hidden = false
			//            MJProgressView.instance.showProgress(self.view, white: true)
			//            UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
			//                self._students = db.getStudentDataFor(Promo: self._teks[self._promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
			//                MJProgressView.instance.hideProgress()
			//                self.navigationItem.titleView = self.resultSearchController.searchBar
			//                self._tableView.reloadData()
			//                self._downloadingView.hidden = true
			//            }
		}
		else {
			self._downloadingView.hidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: "refreshData:", forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
	}
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel) { (action:UIAlertAction!) in
			self._refreshControl.endRefreshing()
			self._downloadingView.hidden = true
			self._tableView.scrollEnabled = true
			self._tableView.userInteractionEnabled = true
			self._promoSelection.userInteractionEnabled = true
			if (self._students.count == 0) {
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
				self._students = db.getStudentDataFor(Promo: self._teks[self._promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
				MJProgressView.instance.hideProgress()
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self._tableView.reloadData()
				self._downloadingView.hidden = true
				self._tableView.scrollEnabled = true
				self._tableView.userInteractionEnabled = true
				self._promoSelection.userInteractionEnabled = true
			}
			
		}
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true, completion:nil)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func refreshData(sender:AnyObject)
	{
		self._tableView.userInteractionEnabled = false
		self._tableView.scrollEnabled = false
		self._promoSelection.userInteractionEnabled = false
		// let db = DBManager.getInstance()
		
		showConfirmationAlert()
		
		//        UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
		//            self._students = db.getStudentDataFor(Promo: self._teks[self._promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		//            self._refreshControl.endRefreshing()
		//            self.navigationItem.titleView = self.resultSearchController.searchBar
		//            self._tableView.reloadData()
		//            self._tableView.userInteractionEnabled = true
		//            self._tableView.scrollEnabled = true
		//            self._promoSelection.userInteractionEnabled = true
		//        }
		
	}
	
	
	@IBAction func segmentedChanged(sender: UISegmentedControl) {
		
		let selected = _teks[sender.selectedSegmentIndex]
		
		self.resultSearchController.searchBar.endEditing(true)
		self.resultSearchController.dismissViewControllerAnimated(true) { () -> Void in
			
		}
		let db = DBManager.getInstance()
		_students = db.getStudentDataFor(Promo: selected) as AnyObject as! [StudentInfo]
		self._tableView.reloadData()
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		resultSearchController.active = false
		if (segue.identifier == "otherUserProfileSegue") {
			let vc = segue.destinationViewController as! OtherUserViewController
			vc._currentUser = _selectedUser
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.active) {
			return _filteredData.count
		}
		return _students.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
		
		let login = cell.viewWithTag(1) as! UILabel
		let city = cell.viewWithTag(2) as! UILabel
		let gpa = cell.viewWithTag(3) as! UILabel
		
		if(resultSearchController.active) {
			login.text = _filteredData[indexPath.row]._login!
			city.text = String(_filteredData[indexPath.row]._position!) + " - " + _filteredData[indexPath.row]._city!
			gpa.text = String(_filteredData[indexPath.row]._gpa!)
		}
		else {
			login.text = _students[indexPath.row]._login!
			city.text = String(_students[indexPath.row]._position!) + " - " + _students[indexPath.row]._city!
			gpa.text = String(_students[indexPath.row]._gpa!)
			
			if (login.text == ApplicationManager.sharedInstance._user?._login!) {
				login.textColor = UIUtils.planningRedColor()
				city.textColor = UIUtils.planningRedColor()
				gpa.textColor = UIUtils.planningRedColor()
			}
			else {
				login.textColor = UIColor.blackColor()
				city.textColor = UIColor.lightGrayColor()
				gpa.textColor = UIColor.blackColor()
			}
			
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.view.endEditing(true)
		let usr = (self.resultSearchController.active == true ? _filteredData[indexPath.row] : _students[indexPath.row])
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		self._promoSelection.userInteractionEnabled = false
		MJProgressView.instance.showProgress(self.view, white: false)
		UserApiCalls.getSelectedUserData(usr._login!) { (isOk :Bool, resp :User?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			}
			else {
				self._selectedUser = resp
				print(self._selectedUser?._login)
				MJProgressView.instance.hideProgress()
				self.performSegueWithIdentifier("otherUserProfileSegue", sender: self)
			}
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			self._promoSelection.userInteractionEnabled = true
		}
		
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
			_filteredData.removeAll(keepCapacity: false)
			let array = _students.filter() { ($0._login?.containsString(searchController.searchBar.text!.lowercaseString))! }
			_filteredData = array
			_tableView.reloadData()
			
		}
		else {
			
			_filteredData.removeAll(keepCapacity: false)
			
			_filteredData = _students
			
			_tableView.reloadData()
			
		}
	}
}
