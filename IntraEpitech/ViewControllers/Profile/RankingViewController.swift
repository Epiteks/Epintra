//
//  RankingViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {
	
	@IBOutlet weak var promoSelection: UISegmentedControl!
	@IBOutlet weak var tableView :UITableView!
	@IBOutlet weak var downloadingView :UIView!
	@IBOutlet weak var downloadingLabel :UILabel!
	
	var students = [StudentInfo]()
	var filteredData = [StudentInfo]()
	
	var teks = ["tech1", "tech2", "tech3", "tech4", "tech5"]
	
	var resultSearchController:UISearchController!
	
	var refreshControl = UIRefreshControl()
	
	var selectedUser :User?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = NSLocalizedString("Ranking", comment: "")
		
		let db = DBManager.getInstance()
		
		promoSelection.setTitle(NSLocalizedString(teks[0], comment: ""), forSegmentAtIndex: 0)
		promoSelection.setTitle(NSLocalizedString(teks[1], comment: ""), forSegmentAtIndex: 1)
		promoSelection.setTitle(NSLocalizedString(teks[2], comment: ""), forSegmentAtIndex: 2)
		promoSelection.setTitle(NSLocalizedString(teks[3], comment: ""), forSegmentAtIndex: 3)
		promoSelection.setTitle(NSLocalizedString(teks[4], comment: ""), forSegmentAtIndex: 4)
		promoSelection.tintColor = UIUtils.backgroundColor()
		
		downloadingLabel.text = NSLocalizedString("DownloadingAllUsers", comment :"")
		
		students = db.getStudentDataFor(Promo: teks[promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
		resultSearchController.searchBar.sizeToFit()
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.whiteColor()
		
		if (students.count == 0) {
			showConfirmationAlert()
			//            self.downloadingView.hidden = false
			//            MJProgressView.instance.showProgress(self.view, white: true)
			//            UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
			//                self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
			//                MJProgressView.instance.hideProgress()
			//                self.navigationItem.titleView = self.resultSearchController.searchBar
			//                self.tableView.reloadData()
			//                self.downloadingView.hidden = true
			//            }
		} else {
			self.downloadingView.hidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(RankingViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel) { (action:UIAlertAction!) in
			self.refreshControl.endRefreshing()
			self.downloadingView.hidden = true
			self.tableView.scrollEnabled = true
			self.tableView.userInteractionEnabled = true
			self.promoSelection.userInteractionEnabled = true
			if (self.students.count == 0) {
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
				self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
				MJProgressView.instance.hideProgress()
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self.tableView.reloadData()
				self.downloadingView.hidden = true
				self.tableView.scrollEnabled = true
				self.tableView.userInteractionEnabled = true
				self.promoSelection.userInteractionEnabled = true
			}
			
		}
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true, completion:nil)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func refreshData(sender:AnyObject) {
		self.tableView.userInteractionEnabled = false
		self.tableView.scrollEnabled = false
		self.promoSelection.userInteractionEnabled = false
		// let db = DBManager.getInstance()
		
		showConfirmationAlert()
		
		//        UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
		//            self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		//            self.refreshControl.endRefreshing()
		//            self.navigationItem.titleView = self.resultSearchController.searchBar
		//            self.tableView.reloadData()
		//            self.tableView.userInteractionEnabled = true
		//            self.tableView.scrollEnabled = true
		//            self.promoSelection.userInteractionEnabled = true
		//        }
		
	}
	
	
	@IBAction func segmentedChanged(sender: UISegmentedControl) {
		
		let selected = teks[sender.selectedSegmentIndex]
		
		self.resultSearchController.searchBar.endEditing(true)
		self.resultSearchController.dismissViewControllerAnimated(true) { () -> Void in
			
		}
		let db = DBManager.getInstance()
		students = db.getStudentDataFor(Promo: selected) as AnyObject as! [StudentInfo]
		self.tableView.reloadData()
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
			vc.currentUser = selectedUser
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.active) {
			return filteredData.count
		}
		return students.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
		
		let login = cell.viewWithTag(1) as! UILabel
		let city = cell.viewWithTag(2) as! UILabel
		let gpa = cell.viewWithTag(3) as! UILabel
		
		if(resultSearchController.active) {
			login.text = filteredData[indexPath.row].login!
			city.text = String(filteredData[indexPath.row].position!) + " - " + filteredData[indexPath.row].city!
			gpa.text = String(filteredData[indexPath.row].gpa!)
		} else {
			login.text = students[indexPath.row].login!
			city.text = String(students[indexPath.row].position!) + " - " + students[indexPath.row].city!
			gpa.text = String(students[indexPath.row].gpa!)
			
			if (login.text == ApplicationManager.sharedInstance.user?.login!) {
				login.textColor = UIUtils.planningRedColor()
				city.textColor = UIUtils.planningRedColor()
				gpa.textColor = UIUtils.planningRedColor()
			} else {
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
		let usr = (self.resultSearchController.active == true ? filteredData[indexPath.row] : students[indexPath.row])
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		self.promoSelection.userInteractionEnabled = false
		MJProgressView.instance.showProgress(self.view, white: false)
		UserApiCalls.getSelectedUserData(usr.login!) { (isOk :Bool, resp :User?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			} else {
				self.selectedUser = resp
				print(self.selectedUser?.login)
				MJProgressView.instance.hideProgress()
				self.performSegueWithIdentifier("otherUserProfileSegue", sender: self)
			}
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			self.promoSelection.userInteractionEnabled = true
		}
		
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
			filteredData.removeAll(keepCapacity: false)
			let array = students.filter() { ($0.login?.containsString(searchController.searchBar.text!.lowercaseString))! }
			filteredData = array
			tableView.reloadData()
			
		} else {
			
			filteredData.removeAll(keepCapacity: false)
			
			filteredData = students
			
			tableView.reloadData()
			
		}
	}
}
