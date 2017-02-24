//
//  SelectCalendarViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 29/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import EventKit

class SelectCalendarViewController: LoadingDataViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
    var calendars: [EKCalendar]?
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Calendars", comment: "")
		
        self.tableView.tableFooterView = UIView()
        
        self.isFetching = true
	}

	override func viewDidAppear(_ animated: Bool) {
		
        let calman = CalendarManager()
		
		CalendarManager.hasRights { [weak self] result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self?.isFetching = true
                    self?.calendars = calman.getAllCalendars()
                    self?.isFetching = false
                    self?.tableView.reloadData()
                }
            case .failure(_):
				self?.isFetching = false
				self?.accessNotGrantedError()
			}
		}
	}
	
	func accessNotGrantedError() {
		
		let alertController = UIAlertController (title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("CalendarAccessDenied", comment: ""), preferredStyle: .alert)
		
		let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { [weak self] _ -> Void in
			DispatchQueue.main.async(execute: {
				let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
				if let url = settingsUrl {
					UIApplication.shared.openURL(url)
				}
				_ = self?.navigationController?.popViewController(animated: true)
			})
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { [weak self] _ -> Void in
            _ = self?.navigationController?.popViewController(animated: true)
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
            if calendarInformations.calendarIdentifier == ApplicationManager.sharedInstance.defaultCalendarIdentifier {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        cell.tintColor = UIUtils.backgroundColor
    
		return cell
	}
	
}

extension SelectCalendarViewController: UITableViewDelegate {
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
        if let calendar = self.calendars?[indexPath.row] {
            
            if calendar.calendarIdentifier == ApplicationManager.sharedInstance.defaultCalendarIdentifier {
                ApplicationManager.sharedInstance.defaultCalendarIdentifier = nil
            } else {
                ApplicationManager.sharedInstance.defaultCalendarIdentifier = calendar.calendarIdentifier
            }
        }
        
        self.tableView.reloadData()
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
