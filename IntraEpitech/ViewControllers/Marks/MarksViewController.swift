//
//  MarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class MarksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	
	@IBOutlet weak var _tableView: UITableView!
	var _marks = [Mark]()
	
	var _marksData : [Mark]?
	var _selectedMark :Mark?
	
	var _refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		self.title = NSLocalizedString("Marks", comment: "")
		
		if (ApplicationManager.sharedInstance._marks != nil) {
			_marks = ApplicationManager.sharedInstance._marks!
		}
		else {
			MJProgressView.instance.showProgress(self.view, white: false)
			MarksApiCalls.getMarks() { (isOk :Bool, resp :[Mark]?, mess :String) in
				
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					self._marks = resp!
					ApplicationManager.sharedInstance._marks = resp!
					self._tableView.reloadData()
				}
				MJProgressView.instance.hideProgress()
			}
		}
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: "refreshData:", forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Marks")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	func refreshData(sender :AnyObject) {
		MarksApiCalls.getMarks() { (isOk :Bool, resp :[Mark]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._marks = resp!
				ApplicationManager.sharedInstance._marks = resp!
				self._tableView.reloadData()
			}
			self._refreshControl.endRefreshing()
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc._marks = _marksData
		}
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		if (_marks.count == 0) {
			tableView.separatorStyle = .None
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _marks.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let moduleLabel = cell?.viewWithTag(2) as! UILabel
		let markLabel = cell?.viewWithTag(3) as! UILabel
		
		let mark = _marks[indexPath.row]
		
		titleLabel.text = mark._title
		moduleLabel.text = mark._titleModule
		markLabel.text = mark._finalNote
		
		cell?.accessoryType = .DisclosureIndicator
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		MarksApiCalls.getProjectMarks(_marks[indexPath.row]) { (isOk :Bool, resp :[Mark]?, mess :String) in
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			MJProgressView.instance.hideProgress()
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._selectedMark = self._marks[indexPath.row]
				self._marksData = resp!
				self.performSegueWithIdentifier("allMarksSegue", sender: self)
			}
		}
	}
	
}
