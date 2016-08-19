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
	
	@IBOutlet weak var tableView: UITableView!
	var marks = [Mark]()
	
	var marksData : [Mark]?
	var selectedMark :Mark?
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Marks", comment: "")
		
		if (ApplicationManager.sharedInstance.marks != nil) {
			marks = ApplicationManager.sharedInstance.marks!
		} else {
			MJProgressView.instance.showProgress(self.view, white: false)
			MarksApiCalls.getMarks() { (isOk :Bool, resp :[Mark]?, mess :String) in
				
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					self.marks = resp!
					ApplicationManager.sharedInstance.marks = resp!
					self.tableView.reloadData()
				}
				MJProgressView.instance.hideProgress()
			}
		}
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(MarksViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(self.refreshControl)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshData(sender :AnyObject) {
		MarksApiCalls.getMarks() { (isOk :Bool, resp :[Mark]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.marks = resp!
				ApplicationManager.sharedInstance.marks = resp!
				self.tableView.reloadData()
			}
			self.refreshControl.endRefreshing()
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc.marks = marksData
		}
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		if (marks.count == 0) {
			tableView.separatorStyle = .None
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return marks.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("marksCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let moduleLabel = cell?.viewWithTag(2) as! UILabel
		let markLabel = cell?.viewWithTag(3) as! UILabel
		
		let mark = marks[indexPath.row]
		
		titleLabel.text = mark.title
		moduleLabel.text = mark.titleModule
		markLabel.text = mark.finalNote
		
		cell?.accessoryType = .DisclosureIndicator
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		MarksApiCalls.getProjectMarks(marks[indexPath.row]) { (isOk :Bool, resp :[Mark]?, mess :String) in
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			MJProgressView.instance.hideProgress()
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.selectedMark = self.marks[indexPath.row]
				self.marksData = resp!
				self.performSegueWithIdentifier("allMarksSegue", sender: self)
			}
		}
	}
	
}
