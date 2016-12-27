//
//  MarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class MarkssViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	
	@IBOutlet weak var tableView: UITableView!
	var marks = [Mark]()
	
	var marksData:  [Mark]?
	var selectedMark: Mark?
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Marks", comment: "")
		
		if (ApplicationManager.sharedInstance.marks != nil) {
			marks = ApplicationManager.sharedInstance.marks!
		} else {
			MJProgressView.instance.showProgress(self.view, white: false)
			MarksApiCalls.getMarks() { (isOk: Bool, resp: [Mark]?, mess: String) in
				
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
		self.refreshControl.addTarget(self, action: #selector(MarkssViewController.refreshData(_:)), for: .valueChanged)
		self.tableView.addSubview(self.refreshControl)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshData(_ sender: AnyObject) {
		MarksApiCalls.getMarks() { (isOk: Bool, resp: [Mark]?, mess: String) in
			
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if (segue.identifier == "allMarksSegue") {
			let vc = segue.destination as! ProjectMarksViewController
			vc.marks = marksData
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		if (marks.count == 0) {
			tableView.separatorStyle = .none
			return 0
		}
		tableView.separatorStyle = .singleLine
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return marks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "marksCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let moduleLabel = cell?.viewWithTag(2) as! UILabel
		let markLabel = cell?.viewWithTag(3) as! UILabel
		
		let mark = marks[(indexPath as NSIndexPath).row]
		
		titleLabel.text = mark.title
		moduleLabel.text = mark.titleModule
		markLabel.text = mark.finalNote
		
		cell?.accessoryType = .disclosureIndicator
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		MarksApiCalls.getProjectMarks(marks[(indexPath as NSIndexPath).row]) { (isOk: Bool, resp: [Mark]?, mess: String) in
			tableView.isUserInteractionEnabled = true
			tableView.isScrollEnabled = true
			MJProgressView.instance.hideProgress()
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.selectedMark = self.marks[(indexPath as NSIndexPath).row]
				self.marksData = resp!
				self.performSegue(withIdentifier: "allMarksSegue", sender: self)
			}
		}
	}
	
}
