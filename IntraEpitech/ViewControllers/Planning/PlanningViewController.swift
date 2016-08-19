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

class PlanningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var calendar: FSCalendar!
	
	var swipeAllowed :Bool?
	
	var currentDate = NSDate()
	
	var currentData = Dictionary<String, [Planning]>()
	var tableViewData = [(String, [Planning])]()
	
	let typeColors = [
		"proj" : UIUtils.planningBlueColor(),
		"rdv" : UIUtils.planningOrangeColor(),
		"tp" : UIUtils.planningPurpleColor(),
		"other" : UIUtils.planningBlueColor(),
		"exam" : UIUtils.planningRedColor(),
		"class" : UIUtils.planningBlueColor()
	]
	
	var refreshControl = UIRefreshControl()
	var savedSemesters :[Bool]? = nil
	var registeredStudentToSend :[RegisteredStudent]?
	var appointmentsToSend :AppointmentEvent? = nil
	
	@IBOutlet weak var selectSemestersButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		swipeAllowed = true
		
		tableView.separatorInset = UIEdgeInsetsZero
		
		calendar.scope = FSCalendarScope.Week
		calendar.firstWeekday = 2
		calendar.weekdayTextColor = UIUtils.backgroundColor()
		calendar.headerTitleColor = UIUtils.backgroundColor()
		calendar.weekdayTextColor = UIUtils.backgroundColor()
		calendar.todayColor = UIUtils.backgroundColor()
		calendar.selectionColor = UIUtils.lightBackgroundColor()
		//calendar.allowsSelection = false
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(PlanningViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(refreshControl)
		self.tableView.allowsMultipleSelectionDuringEditing = true
		
		selectSemestersButton.title = NSLocalizedString("Semesters", comment :"")
		
		if (currentDate.fs_weekday == 1) {
			currentDate = currentDate.fs_dateBySubtractingDays(1)
		}
		
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((currentDate.startOfWeek()?.toAPIString())!, end: (currentDate.endOfWeek()?.toAPIString())!) { _ in
			MJProgressView.instance.hideProgress()
		}
	}
	
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Planning", comment: "")
	}
	
	
	
	override func viewWillAppear(animated: Bool) {
		
		if (self.appointmentsToSend != nil) {
			
			MJProgressView.instance.showProgress(self.view, white: false)
			let cal = calendar.currentPage
			print(calendar.currentPage)
			tableView.userInteractionEnabled = false
			tableView.scrollEnabled = false
			calendar.userInteractionEnabled = false
			PlanningApiCalls.getPlanning((cal.startOfWeek()?.toAPIString())!, last: (cal.endOfWeek()?.toAPIString())!) { (isOk :Bool, planningArray :Dictionary<String, [Planning]>?, mess :String?) in
				
				MJProgressView.instance.hideProgress()
				if (isOk)
				{
					self.currentData = planningArray!
					self.sortDict()
					self.tableView.reloadData()
				}
				else {
				}
				self.tableView.userInteractionEnabled = true
				self.tableView.scrollEnabled = true
				self.calendar.userInteractionEnabled = true
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
	
	func refreshData(sender:AnyObject)
	{
		let week = calendar.currentPage
		
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self.refreshControl.endRefreshing()
		}
	}
	
	func loadData(first :String, end :String, onCompletion :() -> ()) {
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		calendar.userInteractionEnabled = false
		PlanningApiCalls.getPlanning(first, last: end) { (isOk :Bool, planningArray :Dictionary<String, [Planning]>?, mess :String?) in
			
			MJProgressView.instance.hideProgress()
			if (isOk)
			{
				self.currentData = planningArray!
				self.sortDict()
				onCompletion()
				self.tableView.reloadData()
				self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.getCurrentDateInData()), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
			}
			else {
				onCompletion()
			}
			self.tableView.userInteractionEnabled = true
			self.tableView.scrollEnabled = true
			self.calendar.userInteractionEnabled = true
		}
	}
	
	func calendarCurrentPageDidChange(calendar: FSCalendar!) {
		let week = calendar.currentPage
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self.refreshControl.endRefreshing()
		}
	}
	
	func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
		self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.getDateInArray(date)), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
	}
	
	
	func getCurrentDateInData() -> Int
	{
		var res = 0
		
		for data in tableViewData
		{
			if (data.0 == currentDate.toAPIString()) {
				return res
			}
			res += 1
		}
		
		if (currentDate.toAPIString() != tableViewData[tableViewData.count - 1].0.shortToDate().toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func getDateInArray(date :NSDate) -> Int {
		var res = 0
		
		for data in tableViewData
		{
			if (data.0 == date.toAPIString()) {
				return res
			}
			res += 1
		}
		
		if (date.toAPIString() != tableViewData[tableViewData.count - 1].0.shortToDate().toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func sortDict() {
		
		let df = NSDateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		
		let myArrayOfTuples = currentData.sort{ df.dateFromString($0.0)!.compare(df.dateFromString($1.0)!) == .OrderedAscending}
		
		tableViewData = myArrayOfTuples
		
		sortArrays()
	}
	
	func sortArrays() {
		
		let df = NSDateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		
		for (var i = 0; i < tableViewData.count; i += 1)
		{
			let val = tableViewData[i].1
			tableViewData[i].1 = val.sort{ df.dateFromString($0.startTime!)!.compare(df.dateFromString($1.startTime!)!) == .OrderedAscending }
		}
		
		
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		let res = tableViewData.count
		
		tableView.separatorStyle = .SingleLine
		if (res == 0) {
			tableView.separatorStyle = .None
		}
		
		return res
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let arr = tableViewData[section].1
		
		if (arr.count == 0)
		{
			return 1
		}
		
		return arr.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! MGSwipeTableCell
		
		let titleEventLabel = cell.viewWithTag(1) as! UILabel
		let roomEventLabel = cell.viewWithTag(2) as! UILabel
		let startEventLabel = cell.viewWithTag(3) as! UILabel
		let endEventLabel = cell.viewWithTag(4) as! UILabel
		let typeView = cell.viewWithTag(5)
		let statusImageView = cell.viewWithTag(6) as! UIImageView
		let moduleTitle = cell.viewWithTag(10) as! UILabel
		
		cell.delegate = self
		
		if (tableViewData[indexPath.section].1.count == 0) {
			
			let cell2 = tableView.dequeueReusableCellWithIdentifier("EmptyCell")
			
			cell.userInteractionEnabled = false
			let emptyLabel = cell2!.viewWithTag(1) as! UILabel
			emptyLabel.text = NSLocalizedString("EmptyEventCell", comment: "")
			emptyLabel.textColor = UIUtils.backgroundColor()
			return cell2!
		}
		cell.userInteractionEnabled = true
		
		let data = tableViewData[indexPath.section].1[indexPath.row]
		
		let eventTimes = data.getEventTime()
		
		titleEventLabel.text = data.actiTitle
		roomEventLabel.text = data.room?.getRoomCleaned()
		startEventLabel.text = eventTimes.start
		endEventLabel.text = eventTimes.end
		typeView?.backgroundColor = typeColors[data.eventType!]
		moduleTitle.text = data.titleModule!
		
		if (data.eventType == "rdv" && eventTimes.start != data.startTime?.toDate().toEventHour() || eventTimes.end != data.endTime?.toDate().toEventHour()) {
			typeView?.backgroundColor = UIUtils.planningDarkOrangeColor()
		}
		
		changeImageToDisplay(data, imageView: statusImageView)
		statusImageView.imageAtIndexPath = indexPath
		
		
		let singleTap = UITapGestureRecognizer(target: self, action:#selector(PlanningViewController.actionOnImageView(_:)))
		singleTap.numberOfTapsRequired = 1
		
		statusImageView.userInteractionEnabled = true
		statusImageView.addGestureRecognizer(singleTap)
		
		setActionsOnCell(cell, indexPath :indexPath)
		cell.selectionStyle = .None
		
		return cell
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let date = tableViewData[section].0
		
		return "  " + date.shortToDate().toTitleString()
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	
	func setActionsOnCell(cell :MGSwipeTableCell, indexPath :NSIndexPath) {
		
		let createEvent = MGSwipeButton(title: NSLocalizedString("AddInCalendar", comment: ""), icon: nil, backgroundColor: UIUtils.planningBlueColor(), callback: { (sender: MGSwipeTableCell!) -> Bool in
			
			let calman = CalendarManager()
			calman.createEvent(self.tableViewData[indexPath.section].1[indexPath.row]) { (isOk :Bool, mess :String) in
				
				if (!isOk) {
					self.showMessage(NSLocalizedString(mess, comment: ""))
				}
			}
			return true
		})
		
		createEvent.buttonWidth = 110
		
		cell.rightButtons = [createEvent]
		
	}
	
	
	func changeImageToDisplay(data :Planning, imageView :UIImageView) {
		
		if (data.eventType == "rdv") {
			imageView.image = UIImage(named: "rightArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor()
			return
		}
		
		if (data.canEnterToken()) {
			imageView.image = UIImage(named: "Token")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningBlueColor()
		}
		else if (data.canRegister()) {
			imageView.image = UIImage(named: "Register")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningGreenColor()
		}
		else if (data.canUnregister()) {
			imageView.image = UIImage(named: "Unregister")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningRedColor()
		}
		else if (data.isRegistered() && !data.canUnregister()) {
			imageView.image = UIImage(named: "Unregister")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor()
		}
		else if (data.isUnregistered() && !data.canRegister()) {
			imageView.image = UIImage(named: "Register")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningGrayColor()
		}
		else if (data.wasPresent()) {
			imageView.image = UIImage(named: "Done")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningGreenColor()
		}
		else if (data.wasAbsent()) {
			imageView.image = UIImage(named: "Delete")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIUtils.planningRedColor()
		}
		else {
			imageView.image = nil
		}
	}
	
	
	func actionOnImageView(sender :UIGestureRecognizer)
	{
		let tapLocation = sender.locationInView(self.tableView)
		let indexPath = self.tableView.indexPathForRowAtPoint(tapLocation)
		let data = tableViewData[indexPath!.section].1[indexPath!.row]
		
		
		if (data.eventType == "rdv") {
			return
		}
		
		if (data.canEnterToken()) {
			enterTokenAlertView(data, indexPath: indexPath!)
		}
		else if (data.canRegister()) {
			PlanningApiCalls.registerToEvent(data) { (isOk :Bool, mess :String) in
				
				if (!isOk) {
					self.showMessage(mess)
				}
				else {
					// Reload cell
					self.updateEventCell(indexPath!, event: data)
				}
				
			}
		}
		else if (data.canUnregister()) {
			PlanningApiCalls.unregisterToEvent(data) { (isOk :Bool, mess :String) in
				
				if (!isOk) {
					self.showMessage(mess)
				}
				else {
					// Reload cell
					self.updateEventCell(indexPath!, event: data)
				}
			}
		}
		
		print(indexPath)
		
	}
	
	func enterTokenAlertView(planning :Planning, indexPath :NSIndexPath) {
		
		let alertController = UIAlertController(title: NSLocalizedString("Token", comment: ""), message: NSLocalizedString("EnterToken", comment: ""), preferredStyle: .Alert)
		
		let confirmAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: .Default) { _ in
			if let field = alertController.textFields![0] as UITextField? {
				// store your data
				
				PlanningApiCalls.enterToken(planning, token: field.text!) { (isOk :Bool, mess :String) in
					
					if (!isOk)
					{
						self.showMessage(mess)
					}
					else {
						self.updateEventCell(indexPath, event: planning)
					}
				}
				
			} else {
				// user did not fill field
			}
			self.view.endEditing(true)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
			
			self.view.endEditing(true)
			
		}
		
		alertController.addTextFieldWithConfigurationHandler { (textField) in
			textField.placeholder = NSLocalizedString("Token", comment: "")
			textField.keyboardType = UIKeyboardType.NumberPad
		}
		
		alertController.addAction(confirmAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func showMessage(mess :String) {
		let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
		
		alert.title = NSLocalizedString("Error", comment: "")
		alert.message = mess
		
		let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { _ in
			
		}
		alert.addAction(defaultAction)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func updateEventCell(indexPath :NSIndexPath, event :Planning) {
		
		self.tableView.beginUpdates()
		
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		
		MJProgressView.instance.showCellProgress(cell!)
		
		let statusImageView = cell?.viewWithTag(6) as! UIImageView
		
		statusImageView.image = nil
		
		PlanningApiCalls.getSpecialEvent(event) { (isOk :Bool, pl :Planning?, mess :String) in
			
			if (!isOk)
			{
				self.showMessage(mess)
			}
			else {
				self.tableViewData[indexPath.section].1[indexPath.row] = pl!
				
				self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
				self.tableView.endUpdates()
			}
			
			self.tableView.endUpdates()
			MJProgressView.instance.hideProgress()
		}
		
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let data = tableViewData[indexPath.section].1[indexPath.row]
		MJProgressView.instance.showProgress(self.view, white: false)
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		if (data.eventType != "rdv") {
			
			PlanningApiCalls.getStudentsRegistered(data) { (isOk :Bool, res :[RegisteredStudent]?, mess :String) in
				MJProgressView.instance.hideProgress()
				self.tableView.userInteractionEnabled = true
				self.tableView.scrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					self.registeredStudentToSend = res!
					self.performSegueWithIdentifier("showStudentsRegistered", sender: self)
				}
			}
		}
		else {
			PlanningApiCalls.getEventDetails(data) { (isOk :Bool, resp :AppointmentEvent?, mess :String) in
				MJProgressView.instance.hideProgress()
				self.tableView.userInteractionEnabled = true
				self.tableView.scrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					resp?.eventName = data.actiTitle!
					self.appointmentsToSend = resp!
					self.performSegueWithIdentifier("appointmentDetailSegue", sender: self)
				}
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "showStudentsRegistered") {
			let vc = segue.destinationViewController as! StudentRegisteredViewController
			vc.data = registeredStudentToSend!
		}
		else if (segue.identifier == "appointmentDetailSegue") {
			let vc = segue.destinationViewController as! AppointmentDetailViewController
			vc.appointment = appointmentsToSend!
		}
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		
		if (direction == .RightToLeft) {
			return swipeAllowed!
		}
		return false
	}
	
	@IBAction func selectSemestersButtonClicked(sender :AnyObject) {
		savedSemesters = ApplicationManager.sharedInstance.planningSemesters
		performSegueWithIdentifier("selectSemestersSegue", sender: self)
	}
}
