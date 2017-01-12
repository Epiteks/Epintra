//
//  SelectCalendarViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import EventKit

class SelectCalendarViewController: LoadingDataViewController {
	
    var calendars: [EKCalendar]? = nil
	
    var currentCalendar: String?
	var currentCalendarIndex: Int?
	
	var hasRight: Bool!
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		
		self.title = NSLocalizedString("Calendars", comment: "")
		
        self.tableView.tableFooterView = UIView()
        
        self.isFetching = true
		
		self.hasRight = true
	}

	override func viewDidAppear(_ animated: Bool) {
		
        let calman = CalendarManager()
		
		calman.hasRights { (granted: Bool, _) in
			if (!granted) {
				self.isFetching = false
				self.hasRight = false
				self.generateBackgroundView()
				
				self.accessNotGrantedError()
				
			} else {
				self.isFetching = true
				self.generateBackgroundView()
				self.calendars = calman.getAllCalendars()
				self.currentCalendar = ApplicationManager.sharedInstance.defaultCalendar
				self.isFetching = false
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
				_ = self.navigationController?.popViewController(animated: true)
			})
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (_) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
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
	
}

extension SelectCalendarViewController: UITableViewDataSource {
	
    func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.calendars?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell()
		
        if let calendarInformations = self.calendars?[indexPath.row] {
            cell.textLabel?.text = calendarInformations.title
            cell.textLabel?.textColor = UIColor(cgColor: calendarInformations.cgColor)
            if calendarInformations.calendarIdentifier == ApplicationManager.sharedInstance.defaultCalendar {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
//		
//		tableView.beginUpdates()
//		
//		var prevCell: UITableViewCell?
//		var newCell: UITableViewCell?
//		
//		if (currentCalendarIndex != nil) {
//			prevCell = tableView.cellForRow(at: IndexPath(row: currentCalendarIndex!, section: 0))
//			prevCell?.accessoryType = .none
//		}
//		newCell = tableView.cellForRow(at: indexPath)
//		newCell?.accessoryType = .checkmark
		
//		ApplicationManager.sharedInstance.defaultCalendar = calendars[(indexPath as NSIndexPath).row].title
//		currentCalendar = calendars[(indexPath as NSIndexPath).row].title
//		currentCalendarIndex = (indexPath as NSIndexPath).row
//		UserPreferences.savDefaultCalendar(calendars[(indexPath as NSIndexPath).row].title)
		
		tableView.endUpdates()
	}
	
	func generateBackgroundView() {
		
//		if self.isFetching == true {
//			self.tableView.tableFooterView = UIView()
//			self.tableView.backgroundView = LoadingView()
//		} else {
//			if self.calendars.count <= 0 && self.hasRight == true {
//				self.tableView.tableFooterView = UIView()
//				let noData = NoDataView(info:  NSLocalizedString("NoCalendar", comment: ""))
//				self.tableView.backgroundView = noData
//			} else if self.hasRight == false {
//				self.tableView.tableFooterView = UIView()
//				let noData = NoDataView(info:  NSLocalizedString("NoAccessCalendar", comment: ""))
//				self.tableView.backgroundView = noData
//				
//			} else {
//				self.tableView.backgroundView = nil
//			}
//			
//		}
	}
}
