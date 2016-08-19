//
//  SelectCalendarViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SelectCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var _calendars = [String]()
	var _currentCalendar :String?
	var _currentCalendarIndex :Int?
	
	@IBOutlet weak var _tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.title = NSLocalizedString("Calendars", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let calman = CalendarManager()
		calman.hasRights() { (granted :Bool, mess :String?) in
			if (!granted) {
				ErrorViewer.errorPresent(self, mess: NSLocalizedString(mess!, comment: "")) {}
			} else {
				self._calendars = calman.getAllCalendars()
				self._currentCalendar = ApplicationManager.sharedInstance.defaultCalendar
				self._tableView.reloadData()
			}
		}
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
		return _calendars.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell()
		
		cell.selectionStyle = .None
		cell.textLabel?.text = _calendars[indexPath.row]
		if (_calendars[indexPath.row] == _currentCalendar) {
			cell.accessoryType = .Checkmark
			_currentCalendarIndex = indexPath.row
		}
		
		return cell
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.beginUpdates()
		
		var prevCell :UITableViewCell?
		var newCell :UITableViewCell?
		
		if (_currentCalendarIndex != nil) {
			prevCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: _currentCalendarIndex!, inSection: 0))
			prevCell?.accessoryType = .None
		}
		newCell = tableView.cellForRowAtIndexPath(indexPath)
		newCell?.accessoryType = .Checkmark
		
		
		ApplicationManager.sharedInstance.defaultCalendar = _calendars[indexPath.row]
		_currentCalendar = _calendars[indexPath.row]
		_currentCalendarIndex = indexPath.row
		UserPreferences.savDefaultCalendar(_calendars[indexPath.row])
		
		tableView.endUpdates()
	}
}
