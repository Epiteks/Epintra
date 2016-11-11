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
	
	override func viewDidAppear(_ animated: Bool) {
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
		
		let alertController = UIAlertController (title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("CalendarAccessDenied", comment: ""), preferredStyle: .alert)
		
		let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (_) -> Void in
			
			DispatchQueue.main.async(execute: {
				let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
				if let url = settingsUrl {
					UIApplication.shared.openURL(url)
				}
				self.navigationController?.popViewController(animated: true)
			})
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (_) -> Void in
			self.navigationController?.popViewController(animated: true)
		}
		alertController.addAction(settingsAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
		
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
		return calendars.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell()
		
		cell.selectionStyle = .none
		cell.textLabel?.text = calendars[(indexPath as NSIndexPath).row].title
		cell.textLabel?.textColor = UIColor(cgColor: calendars[(indexPath as NSIndexPath).row].color)
		if (calendars[(indexPath as NSIndexPath).row].title == currentCalendar) {
			cell.accessoryType = .checkmark
			currentCalendarIndex = (indexPath as NSIndexPath).row
		}
		
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		tableView.beginUpdates()
		
		var prevCell :UITableViewCell?
		var newCell :UITableViewCell?
		
		if (currentCalendarIndex != nil) {
			prevCell = tableView.cellForRow(at: IndexPath(row: currentCalendarIndex!, section: 0))
			prevCell?.accessoryType = .none
		}
		newCell = tableView.cellForRow(at: indexPath)
		newCell?.accessoryType = .checkmark
		
		
		ApplicationManager.sharedInstance.defaultCalendar = calendars[(indexPath as NSIndexPath).row].title
		currentCalendar = calendars[(indexPath as NSIndexPath).row].title
		currentCalendarIndex = (indexPath as NSIndexPath).row
		UserPreferences.savDefaultCalendar(calendars[(indexPath as NSIndexPath).row].title)
		
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
