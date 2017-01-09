//
//  PlanningViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import FSCalendar
import MGSwipeTableCell

class PlanningViewControllers: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var calendar: FSCalendar!
	
	var swipeAllowed: Bool?
	
	var currentDate = Date()
	
	var currentData = Dictionary<String, [Planning]>()
	var tableViewData = [(String, [Planning])]()
	
	let typeColors = [
		"proj":  UIUtils.planningBlueColor,
		"rdv":  UIUtils.planningOrangeColor,
		"tp":  UIUtils.planningPurpleColor,
		"other":  UIUtils.planningBlueColor,
		"exam":  UIUtils.planningRedColor,
		"class":  UIUtils.planningBlueColor
	]
	
	var refreshControl = UIRefreshControl()
	var savedSemesters: [Bool]? = nil
	var registeredStudentToSend: [RegisteredStudent]?
	var appointmentsToSend: AppointmentEvent? = nil
	
	@IBOutlet weak var selectSemestersButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		swipeAllowed = true
		
		tableView.separatorInset = UIEdgeInsets.zero
		
		calendar.scope = FSCalendarScope.week
		calendar.firstWeekday = 2
		
		calendar.calendarWeekdayView.tintColor = UIUtils.backgroundColor
		/* TODO
		calendar.weekdayTextColor = UIUtils.backgroundColor
		calendar.headerTitleColor = UIUtils.backgroundColor
		calendar.todayColor = UIUtils.backgroundColor
		calendar.selectionColor = UIUtils.lightBackgroundColor*/
		//calendar.allowsSelection = false
		
		self.refreshControl.tintColor = UIUtils.backgroundColor
		//self.refreshControl.addTarget(self, action: #selector(PlanningViewController.refreshData(_:)), for: .valueChanged)
		self.tableView.addSubview(refreshControl)
		self.tableView.allowsMultipleSelectionDuringEditing = true
		
		selectSemestersButton.title = NSLocalizedString("Semesters", comment: "")
		
		//let calendar = NSCalendar(calendarIdentifier: .gregorian)
		
		// TODO
		/*if ((currentDate as Date).fs_weekday == 1) {
			currentDate = (currentDate as Date).fs_date(bySubtractingDays: 1)
		}*/
		
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((currentDate.startOfWeek()?.toAPIString())!, end: (currentDate.endOfWeek()?.toAPIString())!) { _ in
			MJProgressView.instance.hideProgress()
		}
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Planning", comment: "")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		if (self.appointmentsToSend != nil) {
			
			MJProgressView.instance.showProgress(self.view, white: false)
			let cal = calendar.currentPage
			print(calendar.currentPage)
			tableView.isUserInteractionEnabled = false
			tableView.isScrollEnabled = false
			calendar.isUserInteractionEnabled = false
			PlanningApiCalls.getPlanning((cal.startOfWeek()?.toAPIString())!, last: (cal.endOfWeek()?.toAPIString())!) { (isOk: Bool, planningArray: Dictionary<String, [Planning]>?, _) in
				
				MJProgressView.instance.hideProgress()
				if (isOk) {
					self.currentData = planningArray!
					self.sortDict()
					self.tableView.reloadData()
				} else {
				}
				self.tableView.isUserInteractionEnabled = true
				self.tableView.isScrollEnabled = true
				self.calendar.isUserInteractionEnabled = true
			}
		}
		
		if (savedSemesters != nil && savedSemesters! != ApplicationManager.sharedInstance.planningSemesters) {
			MJProgressView.instance.showProgress(self.view, white: false)
			let cal = calendar.currentPage
			print(calendar.currentPage)
			loadData((cal.startOfWeek()?.toAPIString())!, end: (cal.endOfWeek()?.toAPIString())!) { _ in
				MJProgressView.instance.hideProgress()
			}
		}
	}
	
	func refreshData(_ sender: AnyObject) {
		let week = calendar.currentPage
		
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self.refreshControl.endRefreshing()
		}
	}
	
	func loadData(_ first: String, end: String, onCompletion: @escaping () -> Void) {
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		calendar.isUserInteractionEnabled = false
		PlanningApiCalls.getPlanning(first, last: end) { (isOk: Bool, planningArray: Dictionary<String, [Planning]>?, _) in
			
			MJProgressView.instance.hideProgress()
			if (isOk) {
				self.currentData = planningArray!
				self.sortDict()
				onCompletion()
				self.tableView.reloadData()
				self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.getCurrentDateInData()), at: UITableViewScrollPosition.top, animated: true)
			} else {
				onCompletion()
			}
			self.tableView.isUserInteractionEnabled = true
			self.tableView.isScrollEnabled = true
			self.calendar.isUserInteractionEnabled = true
		}
	}
	
	func calendarCurrentPageDidChange(_ calendar: FSCalendar!) {
		let week = calendar.currentPage
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self.refreshControl.endRefreshing()
		}
	}
	
	func calendar(_ calendar: FSCalendar!, didSelectDate date: Date!) {
		self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.getDateInArray(date)), at: UITableViewScrollPosition.top, animated: true)
	}
	
	func getCurrentDateInData() -> Int {
		var res = 0
		
		for data in tableViewData {
			if (data.0 == currentDate.toAPIString()) {
				return res
			}
			res += 1
		}
		
		if (currentDate.toAPIString() != tableViewData[tableViewData.count - 1].0.shortToDate()?.toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func getDateInArray(_ date: Date) -> Int {
		var res = 0
		
		for data in tableViewData {
			if (data.0 == date.toAPIString()) {
				return res
			}
			res += 1
		}
		
		if (date.toAPIString() != tableViewData[tableViewData.count - 1].0.shortToDate()?.toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func sortDict() {
		
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		
		let myArrayOfTuples = currentData.sorted { df.date(from: $0.0)!.compare(df.date(from: $1.0)!) == .orderedAscending}
		
		tableViewData = myArrayOfTuples
		
		sortArrays()
	}
	
	func sortArrays() {
		
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		for i in 0 ..< tableViewData.count {
			let val = tableViewData[i].1
			tableViewData[i].1 = val.sorted { df.date(from: $0.startTime!)!.compare(df.date(from: $1.startTime!)!) == .orderedAscending }
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		let res = tableViewData.count
		
		tableView.separatorStyle = .singleLine
		if (res == 0) {
			tableView.separatorStyle = .none
		}
		
		return res
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let arr = tableViewData[section].1
		
		if (arr.count == 0) {
			return 1
		}
		
		return arr.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! MGSwipeTableCell
		
		let titleEventLabel = cell.viewWithTag(1) as! UILabel
		let roomEventLabel = cell.viewWithTag(2) as! UILabel
		let startEventLabel = cell.viewWithTag(3) as! UILabel
		let endEventLabel = cell.viewWithTag(4) as! UILabel
		let typeView = cell.viewWithTag(5)
		let statusImageView = cell.viewWithTag(6) as! UIImageView
		let moduleTitle = cell.viewWithTag(10) as! UILabel
		
		cell.delegate = self
		
		if (tableViewData[(indexPath as NSIndexPath).section].1.count == 0) {
			
			let cell2 = tableView.dequeueReusableCell(withIdentifier: "EmptyCell")
			
			cell.isUserInteractionEnabled = false
			let emptyLabel = cell2!.viewWithTag(1) as! UILabel
			emptyLabel.text = NSLocalizedString("EmptyEventCell", comment: "")
			emptyLabel.textColor = UIUtils.backgroundColor
			return cell2!
		}
		cell.isUserInteractionEnabled = true
		
		let data = tableViewData[(indexPath as NSIndexPath).section].1[(indexPath as NSIndexPath).row]
		
		let eventTimes = data.getEventTime()
		
		titleEventLabel.text = data.actiTitle
		roomEventLabel.text = data.room?.getRoomCleaned()
		startEventLabel.text = eventTimes.start
		endEventLabel.text = eventTimes.end
		typeView?.backgroundColor = typeColors[data.eventType!]
		moduleTitle.text = data.titleModule!
		
		if (data.eventType == "rdv" && eventTimes.start != data.startTime?.toDate().toEventHour() || eventTimes.end != data.endTime?.toDate().toEventHour()) {
			typeView?.backgroundColor = UIUtils.planningDarkOrangeColor
		}
		
		changeImageToDisplay(data, imageView: statusImageView)
		//statusImageView.imageAtIndexPath = indexPath
		
//		let singleTap = UITapGestureRecognizer(target: self, action:#selector(PlanningViewController.actionOnImageView(_:)))
//		singleTap.numberOfTapsRequired = 1
//		
//		statusImageView.isUserInteractionEnabled = true
//		statusImageView.addGestureRecognizer(singleTap)
		
		setActionsOnCell(cell, indexPath: indexPath)
		cell.selectionStyle = .none
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let date = tableViewData[section].0
		
		return "  " + (date.shortToDate()?.toTitleString())!
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func setActionsOnCell(_ cell: MGSwipeTableCell, indexPath: IndexPath) {
		
		let createEvent = MGSwipeButton(title: NSLocalizedString("AddInCalendar", comment: ""), icon: nil, backgroundColor: UIUtils.planningBlueColor, callback: { (_) -> Bool in
			
			let calman = CalendarManager()
			calman.createEvent(self.tableViewData[(indexPath as NSIndexPath).section].1[(indexPath as NSIndexPath).row]) { (isOk: Bool, mess: String) in
				
				if (!isOk) {
					self.showMessage(NSLocalizedString(mess, comment: ""))
				}
			}
			return true
		})
		
		createEvent.buttonWidth = 110
		
		cell.rightButtons = [createEvent]
		
	}
	
	func changeImageToDisplay(_ data: Planning, imageView: UIImageView) {
		
		if (data.eventType == "rdv") {
			imageView.image = UIImage(named: "rightArrow")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor
			return
		}
		
		if (data.canEnterToken()) {
			imageView.image = UIImage(named: "Token")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningBlueColor
		} else if (data.canRegister()) {
			imageView.image = UIImage(named: "Register")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningGreenColor
		} else if (data.canUnregister()) {
			imageView.image = UIImage(named: "Unregister")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningRedColor
		} else if (data.isRegistered() && !data.canUnregister()) {
			imageView.image = UIImage(named: "Unregister")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor
		} else if (data.isUnregistered() && !data.canRegister()) {
			imageView.image = UIImage(named: "Register")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor
		} else if (data.wasPresent()) {
			imageView.image = UIImage(named: "Done")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningGreenColor
		} else if (data.wasAbsent()) {
			imageView.image = UIImage(named: "Delete")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			imageView.tintColor = UIUtils.planningRedColor
		} else {
			imageView.image = nil
		}
	}
	
	func actionOnImageView(_ sender: UIGestureRecognizer) {
		let tapLocation = sender.location(in: self.tableView)
		let indexPath = self.tableView.indexPathForRow(at: tapLocation)
		let data = tableViewData[(indexPath! as NSIndexPath).section].1[(indexPath! as NSIndexPath).row]
		
		if (data.eventType == "rdv") {
			return
		}
		
		if (data.canEnterToken()) {
			enterTokenAlertView(data, indexPath: indexPath!)
		} else if (data.canRegister()) {
			PlanningApiCalls.registerToEvent(data) { (isOk: Bool, mess: String) in
				
				if (!isOk) {
					self.showMessage(mess)
				} else {
					// Reload cell
					self.updateEventCell(indexPath!, event: data)
				}
				
			}
		} else if (data.canUnregister()) {
			PlanningApiCalls.unregisterToEvent(data) { (isOk: Bool, mess: String) in
				
				if (!isOk) {
					self.showMessage(mess)
				} else {
					// Reload cell
					self.updateEventCell(indexPath!, event: data)
				}
			}
		}
		
		print(indexPath)
		
	}
	
	func enterTokenAlertView(_ planning: Planning, indexPath: IndexPath) {
		
		let alertController = UIAlertController(title: NSLocalizedString("Token", comment: ""), message: NSLocalizedString("EnterToken", comment: ""), preferredStyle: .alert)
		
		let confirmAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: .default) { _ in
			if let field = alertController.textFields![0] as UITextField? {
				// store your data
				
				PlanningApiCalls.enterToken(planning, token: field.text!) { (isOk: Bool, mess: String) in
					
					if (!isOk) {
						self.showMessage(mess)
					} else {
						self.updateEventCell(indexPath, event: planning)
					}
				}
				
			} else {
				// user did not fill field
			}
			self.view.endEditing(true)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
			
			self.view.endEditing(true)
			
		}
		
		alertController.addTextField { (textField) in
			textField.placeholder = NSLocalizedString("Token", comment: "")
			textField.keyboardType = UIKeyboardType.numberPad
		}
		
		alertController.addAction(confirmAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func showMessage(_ mess: String) {
		let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
		
		alert.title = NSLocalizedString("Error", comment: "")
		alert.message = mess
		
		let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { _ in
			
		}
		alert.addAction(defaultAction)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func updateEventCell(_ indexPath: IndexPath, event: Planning) {
		
		self.tableView.beginUpdates()
		
		let cell = self.tableView.cellForRow(at: indexPath)
		
		MJProgressView.instance.showCellProgress(cell!)
		
		let statusImageView = cell?.viewWithTag(6) as! UIImageView
		
		statusImageView.image = nil
		
		PlanningApiCalls.getSpecialEvent(event) { (isOk: Bool, pl: Planning?, mess: String) in
			
			if (!isOk) {
				self.showMessage(mess)
			} else {
				self.tableViewData[(indexPath as NSIndexPath).section].1[(indexPath as NSIndexPath).row] = pl!
				
				self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
				self.tableView.endUpdates()
			}
			
			self.tableView.endUpdates()
			MJProgressView.instance.hideProgress()
		}
		
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let data = tableViewData[(indexPath as NSIndexPath).section].1[(indexPath as NSIndexPath).row]
		MJProgressView.instance.showProgress(self.view, white: false)
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		if (data.eventType != "rdv") {
			
			PlanningApiCalls.getStudentsRegistered(data) { (isOk: Bool, res: [RegisteredStudent]?, mess: String) in
				MJProgressView.instance.hideProgress()
				self.tableView.isUserInteractionEnabled = true
				self.tableView.isScrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					self.registeredStudentToSend = res!
					self.performSegue(withIdentifier: "showStudentsRegistered", sender: self)
				}
			}
		} else {
			PlanningApiCalls.getEventDetails(data) { (isOk: Bool, resp: AppointmentEvent?, mess: String) in
				MJProgressView.instance.hideProgress()
				self.tableView.isUserInteractionEnabled = true
				self.tableView.isScrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					resp?.eventName = data.actiTitle!
					self.appointmentsToSend = resp!
					self.performSegue(withIdentifier: "appointmentDetailSegue", sender: self)
				}
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "showStudentsRegistered") {
			let vc = segue.destination as! StudentRegisteredViewController
			vc.data = registeredStudentToSend!
		} else if (segue.identifier == "appointmentDetailSegue") {
			let vc = segue.destination as! AppointmentDetailViewController
			vc.appointment = appointmentsToSend!
		}
	}
	
	func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
		
		if (direction == .rightToLeft) {
			return swipeAllowed!
		}
		return false
	}
	
	@IBAction func selectSemestersButtonClicked(_ sender: AnyObject) {
		savedSemesters = ApplicationManager.sharedInstance.planningSemesters
		performSegue(withIdentifier: "selectSemestersSegue", sender: self)
	}
}
