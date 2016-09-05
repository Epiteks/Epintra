//
//  SelectCalendarViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SelectCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var calendars = [(title: String, color: CGColor)]()
	var currentCalendar :String?
	var currentCalendarIndex :Int?
	
	var isLoading: Bool?
	
	var tableFooterSave: UIView!
	var hasRight: Bool!
	
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.tableFooterSave = self.tableView.tableFooterView
		
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
				self.calendars = calman.getAllCalendars()
				self.currentCalendar = ApplicationManager.sharedInstance.defaultCalendar
				self.isLoading = false
				self.generateBackgroundView()
				self.tableView.reloadData()
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
				self.navigationController?.popViewControllerAnimated(true)
			})
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { (_) -> Void in
			self.navigationController?.popViewControllerAnimated(true)
		}
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
		return calendars.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell()
		
		cell.selectionStyle = .None
		cell.textLabel?.text = calendars[indexPath.row].title
		cell.textLabel?.textColor = UIColor(CGColor: calendars[indexPath.row].color)
		if (calendars[indexPath.row].title == currentCalendar) {
			cell.accessoryType = .Checkmark
			currentCalendarIndex = indexPath.row
		}
		
		return cell
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.beginUpdates()
		
		var prevCell :UITableViewCell?
		var newCell :UITableViewCell?
		
		if (currentCalendarIndex != nil) {
			prevCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: currentCalendarIndex!, inSection: 0))
			prevCell?.accessoryType = .None
		}
		newCell = tableView.cellForRowAtIndexPath(indexPath)
		newCell?.accessoryType = .Checkmark
		
		
		ApplicationManager.sharedInstance.defaultCalendar = calendars[indexPath.row].title
		currentCalendar = calendars[indexPath.row].title
		currentCalendarIndex = indexPath.row
		UserPreferences.savDefaultCalendar(calendars[indexPath.row].title)
		
		tableView.endUpdates()
	}
	
	func generateBackgroundView() {
		
		if self.isLoading == true {
			self.tableView.tableFooterView = UIView()
			self.tableView.backgroundView = LoadingView()
		} else {
			if self.calendars.count <= 0 && self.hasRight == true {
				self.tableView.tableFooterView = UIView()
				let noData = NoDataView(info:  NSLocalizedString("NoCalendar", comment: ""))
				self.tableView.backgroundView = noData
			} else if self.hasRight == false {
				self.tableView.tableFooterView = UIView()
				let noData = NoDataView(info:  NSLocalizedString("NoAccessCalendar", comment: ""))
				self.tableView.backgroundView = noData
				
			} else {
				self.tableView.tableFooterView = self.tableFooterSave
				self.tableView.backgroundView = nil
			}
			
			
		}
	}
}
