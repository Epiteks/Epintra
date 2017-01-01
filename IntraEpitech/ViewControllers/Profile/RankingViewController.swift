//
//  RankingViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
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

fileprivate func > <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {
	
	@IBOutlet weak var promoSelection: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var downloadingView: UIView!
	@IBOutlet weak var downloadingLabel: UILabel!
	
	var students = [StudentInfo]()
	var filteredData = [StudentInfo]()
	
	var teks = ["tech1", "tech2", "tech3", "tech4", "tech5"]
	
	var resultSearchController:UISearchController!
	
	var refreshControl = UIRefreshControl()
	
	var selectedUser: User?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = NSLocalizedString("Ranking", comment: "")
		
		let db = DBManager.getInstance()
		
		promoSelection.setTitle(NSLocalizedString(teks[0], comment: ""), forSegmentAt: 0)
		promoSelection.setTitle(NSLocalizedString(teks[1], comment: ""), forSegmentAt: 1)
		promoSelection.setTitle(NSLocalizedString(teks[2], comment: ""), forSegmentAt: 2)
		promoSelection.setTitle(NSLocalizedString(teks[3], comment: ""), forSegmentAt: 3)
		promoSelection.setTitle(NSLocalizedString(teks[4], comment: ""), forSegmentAt: 4)
		promoSelection.tintColor = UIUtils.backgroundColor()
		
		downloadingLabel.text = NSLocalizedString("DownloadingAllUsers", comment: "")
		
		students = db.getStudentDataFor(Promo: teks[promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
		resultSearchController.searchBar.sizeToFit()
		
		resultSearchController.searchBar.barTintColor = UIUtils.backgroundColor()
		resultSearchController.searchBar.tintColor = UIColor.white
		
		if (students.count == 0) {
			showConfirmationAlert()
			//            self.downloadingView.hidden = false
			//            MJProgressView.instance.showProgress(self.view, white: true)
			//            UserApiCalls.getAllUsers() { (isOk: Bool, res: [StudentInfo]?, mess: String) in
			//                self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
			//                MJProgressView.instance.hideProgress()
			//                self.navigationItem.titleView = self.resultSearchController.searchBar
			//                self.tableView.reloadData()
			//                self.downloadingView.hidden = true
			//            }
		} else {
			self.downloadingView.isHidden = true
			self.navigationItem.titleView = resultSearchController.searchBar
		}
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(RankingViewController.refreshData(_:)), for: .valueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func showConfirmationAlert() {
		
		let alertController = UIAlertController(title: NSLocalizedString("DataDownload", comment: ""), message: NSLocalizedString("SureWantsDownloadData", comment: ""), preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel) { (_) in
			self.refreshControl.endRefreshing()
			self.downloadingView.isHidden = true
			self.tableView.isScrollEnabled = true
			self.tableView.isUserInteractionEnabled = true
			self.promoSelection.isUserInteractionEnabled = true
			if (self.students.count == 0) {
				self.navigationController?.popViewController(animated: true)
			}
		}
		alertController.addAction(cancelAction)
		
		let OKAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (_) in
			self.refreshControl.endRefreshing()
			let db = DBManager.getInstance()
			self.downloadingView.isHidden = false
			MJProgressView.instance.showProgress(self.view, white: true)
			UserApiCalls.getAllUsers() { (_, _, _) in
				self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
				MJProgressView.instance.hideProgress()
				self.navigationItem.titleView = self.resultSearchController.searchBar
				self.tableView.reloadData()
				self.downloadingView.isHidden = true
				self.tableView.isScrollEnabled = true
				self.tableView.isUserInteractionEnabled = true
				self.promoSelection.isUserInteractionEnabled = true
			}
			
		}
		alertController.addAction(OKAction)
		
		self.present(alertController, animated: true, completion:nil)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.resultSearchController.searchBar.endEditing(true)
	}
	
	func refreshData(_ sender:AnyObject) {
		self.tableView.isUserInteractionEnabled = false
		self.tableView.isScrollEnabled = false
		self.promoSelection.isUserInteractionEnabled = false
		// let db = DBManager.getInstance()
		
		showConfirmationAlert()
		
		//        UserApiCalls.getAllUsers() { (isOk: Bool, res: [StudentInfo]?, mess: String) in
		//            self.students = db.getStudentDataFor(Promo: self.teks[self.promoSelection.selectedSegmentIndex]) as AnyObject as! [StudentInfo]
		//            self.refreshControl.endRefreshing()
		//            self.navigationItem.titleView = self.resultSearchController.searchBar
		//            self.tableView.reloadData()
		//            self.tableView.userInteractionEnabled = true
		//            self.tableView.scrollEnabled = true
		//            self.promoSelection.userInteractionEnabled = true
		//        }
		
	}
	
	@IBAction func segmentedChanged(_ sender: UISegmentedControl) {
		
		let selected = teks[sender.selectedSegmentIndex]
		
		self.resultSearchController.searchBar.endEditing(true)
		self.resultSearchController.dismiss(animated: true) { () -> Void in
			
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		resultSearchController.isActive = false
		if (segue.identifier == "otherUserProfileSegue") {
			let vc = segue.destination as! OtherUserViewController
			vc.currentUser = selectedUser
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(resultSearchController.isActive) {
			return filteredData.count
		}
		return students.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
		
//		let login = cell.viewWithTag(1) as! UILabel
//		let city = cell.viewWithTag(2) as! UILabel
//		let gpa = cell.viewWithTag(3) as! UILabel
//		
//		if(resultSearchController.isActive) {
//			login.text = filteredData[(indexPath as NSIndexPath).row].login!
//			city.text = String(filteredData[(indexPath as NSIndexPath).row].position!) + " - " + filteredData[(indexPath as NSIndexPath).row].city!
////			gpa.text = String(filteredData[(indexPath as NSIndexPath).row].gpa!)
//		} else {
//			login.text = students[(indexPath as NSIndexPath).row].login!
//			city.text = String(students[(indexPath as NSIndexPath).row].position!) + " - " + students[(indexPath as NSIndexPath).row].city!
////			gpa.text = String(students[(indexPath as NSIndexPath).row].gpa!)
//			
//			if (login.text == ApplicationManager.sharedInstance.user?.login!) {
//				login.textColor = UIUtils.planningRedColor()
//				city.textColor = UIUtils.planningRedColor()
//				gpa.textColor = UIUtils.planningRedColor()
//			} else {
//				login.textColor = UIColor.black
//				city.textColor = UIColor.lightGray
//				gpa.textColor = UIColor.black
//			}
//			
//		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		
//		tableView.deselectRow(at: indexPath, animated: true)
//		self.view.endEditing(true)
//		let usr = (self.resultSearchController.isActive == true ? filteredData[(indexPath as NSIndexPath).row]:  students[(indexPath as NSIndexPath).row])
//		
//		tableView.isUserInteractionEnabled = false
//		tableView.isScrollEnabled = false
//		self.promoSelection.isUserInteractionEnabled = false
//		MJProgressView.instance.showProgress(self.view, white: false)
//		UserApiCalls.getSelectedUserData(usr.login!) { (isOk: Bool, resp: User?, mess: String) in
//			
//			if (!isOk) {
//				ErrorViewer.errorPresent(self, mess: mess) {}
//				MJProgressView.instance.hideProgress()
//			} else {
//				self.selectedUser = resp
//				print(self.selectedUser?.login)
//				MJProgressView.instance.hideProgress()
//				self.performSegue(withIdentifier: "otherUserProfileSegue", sender: self)
//			}
//			tableView.isUserInteractionEnabled = true
//			tableView.isScrollEnabled = true
//			self.promoSelection.isUserInteractionEnabled = true
//		}
		
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		if searchController.searchBar.text?.characters.count > 0 {
//			filteredData.removeAll(keepingCapacity: false)
//			let array = students.filter() { ($0.login?.contains(searchController.searchBar.text!.lowercased()))! }
//			filteredData = array
//			tableView.reloadData()
			
		} else {
			
			filteredData.removeAll(keepingCapacity: false)
			
			filteredData = students
			
			tableView.reloadData()
			
		}
	}
}
