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
	
	var isLoading: Bool?
	
	var tableFooterSave: UIView!
	var hasRight: Bool!
	
	@IBOutlet weak var _tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.tableFooterSave = self._tableView.tableFooterView
		
		self.title = NSLocalizedString("Calendars", comment: "")
		//self.isLoading = false
		self.isLoading = true
		self.generateBackgroundView()
		self.hasRight = true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let calman = CalendarManager()
		
		
		
		calman.hasRights() { (granted :Bool, mess :String?) in
			if (!granted) {
				self.isLoading = false
				self.hasRight = false
				self.generateBackgroundView()
				
				self.accessNotGrantedError()
				
				
			} else {
				self.isLoading = true
				self.generateBackgroundView()
				self._calendars = calman.getAllCalendars()
				self._currentCalendar = ApplicationManager.sharedInstance.defaultCalendar
				self.isLoading = false
				self.generateBackgroundView()
				self._tableView.reloadData()
			}
		}
	}
	
	func accessNotGrantedError() {
		
		let alertController = UIAlertController (title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("CalendarAccessDenied", comment: ""), preferredStyle: .Alert)
		
		let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .Default) { (_) -> Void in
			
			dispatch_async(dispatch_get_main_queue(), {
				let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
				if let url = settingsUrl {
					UIApplication.sharedApplication().openURL(url)
				}
			})
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: nil)
		alertController.addAction(settingsAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
		
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
	
	func generateBackgroundView() {
		
		if self.isLoading == true {
			self._tableView.tableFooterView = UIView()
			self._tableView.backgroundView = LoadingView()
		} else {
			if self._calendars.count <= 0 && self.hasRight == true {
				self._tableView.tableFooterView = UIView()
				let noData = NoDataView(info:  NSLocalizedString("NoCalendar", comment: ""))
				self._tableView.backgroundView = noData
			} else if self.hasRight == false {
				self._tableView.tableFooterView = UIView()
				let noData = NoDataView(info:  NSLocalizedString("NoAccessCalendar", comment: ""))
				self._tableView.backgroundView = noData
				
			} else {
				self._tableView.tableFooterView = self.tableFooterSave
				self._tableView.backgroundView = nil
			}
			
			
		}
	}
}
