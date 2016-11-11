//
//  SearchUserViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
		resultSearchController.searchBar.sizeToFit()
		//self.tableView.tableHeaderView = resultSearchController.searchBar
		
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.white
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
			self.downloadingView.isHidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(SearchUserViewController.refreshData(_:)), for: .valueChanged)
		
		self.tableView.addSubview(refreshControl)
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel) { (action:UIAlertAction!) in
			self.refreshControl.endRefreshing()
			self.downloadingView.isHidden = true
			self.tableView.isScrollEnabled = true
			self.tableView.isUserInteractionEnabled = true
			if (self.users.count == 0) {
				self.navigationController?.popViewController(animated: true)
			}
		}
		alertController.addAction(cancelAction)
		
		let OKAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (action:UIAlertAction!) in
			self.refreshControl.endRefreshing()
			let db = DBManager.getInstance()
			self.downloadingView.isHidden = false
			MJProgressView.instance.showProgress(self.view, white: true)
			/*
			UserApiCalls.getAllUsers() { (isOk :Bool, res :[StudentInfo]?, mess :String) in
				self.users = db.getAllStudentData() as AnyObject as! [StudentInfo]
				self.refreshControl.endRefreshing()
				MJProgressView.instance.hideProgress()
				self.downloadingView.isHidden = true
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self.tableView.reloadData()
				self.tableView.isUserInteractionEnabled = true
				self.tableView.isScrollEnabled = true
			}*/
		}
		alertController.addAction(OKAction)
		
		self.present(alertController, animated: true, completion:nil)
	}
	
	
	func refreshData(_ sender:AnyObject) {
		self.tableView.isUserInteractionEnabled = false
		self.tableView.isScrollEnabled = false
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
	
	override func viewDidAppear(_ animated: Bool) {
		tableView.isUserInteractionEnabled = true
		tableView.isScrollEnabled = true
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.isActive) {
			return filteredData.count
		}
		return users.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell;
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
		
		let loginTitle = cell?.viewWithTag(1) as! UILabel
		let promo = cell?.viewWithTag(2) as! UILabel
		let city = cell?.viewWithTag(3) as! UILabel
		
		if(resultSearchController.isActive) {
			loginTitle.text = filteredData[(indexPath as NSIndexPath).row].login
			promo.text = NSLocalizedString(String(filteredData[(indexPath as NSIndexPath).row].promo!), comment: "")
			city.text = filteredData[(indexPath as NSIndexPath).row].city
		} else {
			loginTitle.text = users[(indexPath as NSIndexPath).row].login
			promo.text = NSLocalizedString(String(users[(indexPath as NSIndexPath).row].promo!), comment: "")
			city.text = users[(indexPath as NSIndexPath).row].city
		}
		
		return cell!
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
			filteredData.removeAll(keepingCapacity: false)
			let array = users.filter() { ($0.login?.contains(searchController.searchBar.text!.lowercased()))! }
			filteredData = array
			tableView.reloadData()
			
		} else {
			
			filteredData.removeAll(keepingCapacity: false)
			
			filteredData = users
			
			tableView.reloadData()
			
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		resultSearchController.isActive = false
		if (segue.identifier == "otherUserProfileSegue") {
			let vc = segue.destination as! OtherUserViewController
			vc.currentUser = selectedUser
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.view.endEditing(true)
		let usr = (self.resultSearchController.isActive == true ? filteredData[(indexPath as NSIndexPath).row] : users[(indexPath as NSIndexPath).row])
		
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		MJProgressView.instance.showProgress(self.view, white: false)
		/*UserApiCalls.getSelectedUserData(usr.login!) { (isOk :Bool, resp :User?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
				tableView.isUserInteractionEnabled = false
				tableView.isScrollEnabled = false
			} else {
				self.selectedUser = resp
				print(self.selectedUser?.login)
				MJProgressView.instance.hideProgress()
				self.performSegue(withIdentifier: "otherUserProfileSegue", sender: self)
				
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
		
	}*/
	
}
}
