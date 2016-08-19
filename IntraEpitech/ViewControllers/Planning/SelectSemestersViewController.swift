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
		
		self.title = NSLocalizedString("Semesters", comment :"")
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(SelectSemestersViewController.backButtonAction(_:))))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil

	}
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
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
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _semesters.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		if (_semesters[indexPath.row] == true) {
			cell.accessoryType = .Checkmark
		}
		else {
			cell.accessoryType = .None
		}
		
		cell.textLabel!.text = NSLocalizedString("Semester", comment :"") + " " + String(indexPath.row)
		
		return cell;
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.beginUpdates()
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		_semesters[indexPath.row] = !_semesters[indexPath.row]
		ApplicationManager.sharedInstance.planningSemesters = _semesters
		cell?.accessoryType = (cell?.accessoryType == .Checkmark ? .None : .Checkmark)
		UserPreferences.saveSemesters(_semesters)
		tableView.endUpdates()
	}
}
