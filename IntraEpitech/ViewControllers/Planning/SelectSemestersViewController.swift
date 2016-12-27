//
//  SelectSemestersViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 06/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SelectSemestersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var _semesters = ApplicationManager.sharedInstance.planningSemesters
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.title = NSLocalizedString("Semesters", comment: "")
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _semesters.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		if (_semesters[(indexPath as NSIndexPath).row] == true) {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		cell.textLabel!.text = NSLocalizedString("Semester", comment: "") + " " + String((indexPath as NSIndexPath).row)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		tableView.beginUpdates()
		let cell = tableView.cellForRow(at: indexPath)
		_semesters[(indexPath as NSIndexPath).row] = !_semesters[(indexPath as NSIndexPath).row]
		ApplicationManager.sharedInstance.planningSemesters = _semesters
		cell?.accessoryType = (cell?.accessoryType == .checkmark ? .none:  .checkmark)
		UserPreferences.saveSemesters(_semesters)
		tableView.endUpdates()
	}
}
