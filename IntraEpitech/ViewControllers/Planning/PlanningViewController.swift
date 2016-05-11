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
	@IBOutlet weak var _tableView: UITableView!
	@IBOutlet weak var _calendar: FSCalendar!
	
	var _swipeAllowed :Bool?
	
	var _currentDate = NSDate()
	
	var _currentData = Dictionary<String, [Planning]>()
	var _tableViewData = [(String, [Planning])]()
	
	let _typeColors = [
		"proj" : UIUtils.planningBlueColor(),
		"rdv" : UIUtils.planningOrangeColor(),
		"tp" : UIUtils.planningPurpleColor(),
		"other" : UIUtils.planningBlueColor(),
		"exam" : UIUtils.planningRedColor(),
		"class" : UIUtils.planningBlueColor()
	]
	
	var _refreshControl = UIRefreshControl()
	var _savedSemesters :[Bool]? = nil
	var _registeredStudentToSend :[RegisteredStudent]?
	var _appointmentsToSend :AppointmentEvent? = nil
	
	@IBOutlet weak var _selectSemestersButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_swipeAllowed = true
		
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		
		
		self.title = NSLocalizedString("Planning", comment: "")
		_tableView.separatorInset = UIEdgeInsetsZero
		
		_calendar.scope = FSCalendarScope.Week
		_calendar.firstWeekday = 2
		_calendar.weekdayTextColor = UIUtils.backgroundColor()
		_calendar.headerTitleColor = UIUtils.backgroundColor()
		_calendar.weekdayTextColor = UIUtils.backgroundColor()
		_calendar.todayColor = UIUtils.backgroundColor()
		_calendar.selectionColor = UIUtils.lightBackgroundColor()
		//_calendar.allowsSelection = false
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: "refreshData:", forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
		self._tableView.allowsMultipleSelectionDuringEditing = true
		
		_selectSemestersButton.title = NSLocalizedString("Semesters", comment :"")
		
		if (_currentDate.fs_weekday == 1) {
			_currentDate = _currentDate.fs_dateBySubtractingDays(1)
		}
		
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((_currentDate.startOfWeek()?.toAPIString())!, end: (_currentDate.endOfWeek()?.toAPIString())!) { _ in
			MJProgressView.instance.hideProgress()
		}
	}
	
	
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Planning")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
		if (self._appointmentsToSend != nil) {
			
			MJProgressView.instance.showProgress(self.view, white: false)
			let cal = _calendar.currentPage
			print(_calendar.currentPage)
			_tableView.userInteractionEnabled = false
			_tableView.scrollEnabled = false
			_calendar.userInteractionEnabled = false
			PlanningApiCalls.getPlanning((cal.startOfWeek()?.toAPIString())!, last: (cal.endOfWeek()?.toAPIString())!) { (isOk :Bool, planningArray :Dictionary<String, [Planning]>?, mess :String?) in
				
				MJProgressView.instance.hideProgress()
				if (isOk)
				{
					self._currentData = planningArray!
					self.sortDict()
					self._tableView.reloadData()
				}
				else {
				}
				self._tableView.userInteractionEnabled = true
				self._tableView.scrollEnabled = true
				self._calendar.userInteractionEnabled = true
			}
		}
		
		if (_savedSemesters != nil && _savedSemesters! != ApplicationManager.sharedInstance._planningSemesters) {
			MJProgressView.instance.showProgress(self.view, white: false)
			let cal = _calendar.currentPage
			print(_calendar.currentPage)
			loadData((cal.startOfWeek()?.toAPIString())!, end: (cal.endOfWeek()?.toAPIString())!) { _ in
				MJProgressView.instance.hideProgress()
			}
		}
	}
	
	func refreshData(sender:AnyObject)
	{
		let week = _calendar.currentPage
		
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self._refreshControl.endRefreshing()
		}
	}
	
	func loadData(first :String, end :String, onCompletion :() -> ()) {
		_tableView.userInteractionEnabled = false
		_tableView.scrollEnabled = false
		_calendar.userInteractionEnabled = false
		PlanningApiCalls.getPlanning(first, last: end) { (isOk :Bool, planningArray :Dictionary<String, [Planning]>?, mess :String?) in
			
			MJProgressView.instance.hideProgress()
			if (isOk)
			{
				self._currentData = planningArray!
				self.sortDict()
				onCompletion()
				self._tableView.reloadData()
				self._tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.getCurrentDateInData()), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
			}
			else {
				onCompletion()
			}
			self._tableView.userInteractionEnabled = true
			self._tableView.scrollEnabled = true
			self._calendar.userInteractionEnabled = true
		}
	}
	
	func calendarCurrentPageDidChange(calendar: FSCalendar!) {
		let week = _calendar.currentPage
		MJProgressView.instance.showProgress(self.view, white: false)
		loadData((week.startOfWeek()?.toAPIString())!, end: (week.endOfWeek()?.toAPIString())!) { _ in
			self._refreshControl.endRefreshing()
		}
	}
	
	func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
		self._tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.getDateInArray(date)), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
	}
	
	
	func getCurrentDateInData() -> Int
	{
		var res = 0
		
		for data in _tableViewData
		{
			if (data.0 == _currentDate.toAPIString()) {
				return res
			}
			res++
		}
		
		if (_currentDate.toAPIString() != _tableViewData[_tableViewData.count - 1].0.shortToDate().toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func getDateInArray(date :NSDate) -> Int {
		var res = 0
		
		for data in _tableViewData
		{
			if (data.0 == date.toAPIString()) {
				return res
			}
			res++
		}
		
		if (date.toAPIString() != _tableViewData[_tableViewData.count - 1].0.shortToDate().toAPIString()) {
			return 0
		}
		
		return res
	}
	
	func sortDict() {
		
		let df = NSDateFormatter()
		df.dateFormat = "yyyy-MM-dd"
		
		let myArrayOfTuples = _currentData.sort{ df.dateFromString($0.0)!.compare(df.dateFromString($1.0)!) == .OrderedAscending}
		
		_tableViewData = myArrayOfTuples
		
		sortArrays()
	}
	
	func sortArrays() {
		
		let df = NSDateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		
		for (var i = 0; i < _tableViewData.count; i++)
		{
			let val = _tableViewData[i].1
			_tableViewData[i].1 = val.sort{ df.dateFromString($0._startTime!)!.compare(df.dateFromString($1._startTime!)!) == .OrderedAscending }
		}
		
		
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		let res = _tableViewData.count
		
		_tableView.separatorStyle = .SingleLine
		if (res == 0) {
			_tableView.separatorStyle = .None
		}
		
		return res
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let arr = _tableViewData[section].1
		
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
		
		if (_tableViewData[indexPath.section].1.count == 0) {
			
			let cell2 = tableView.dequeueReusableCellWithIdentifier("EmptyCell")
			
			cell.userInteractionEnabled = false
			let emptyLabel = cell2!.viewWithTag(1) as! UILabel
			emptyLabel.text = NSLocalizedString("EmptyEventCell", comment: "")
			emptyLabel.textColor = UIUtils.backgroundColor()
			return cell2!
		}
		cell.userInteractionEnabled = true
		
		let data = _tableViewData[indexPath.section].1[indexPath.row]
		
		let eventTimes = data.getEventTime()
		
		titleEventLabel.text = data._actiTitle
		roomEventLabel.text = data._room?.getRoomCleaned()
		startEventLabel.text = eventTimes.start
		endEventLabel.text = eventTimes.end
		typeView?.backgroundColor = _typeColors[data._eventType!]
		moduleTitle.text = data._titleModule!
		
		if (data._eventType == "rdv" && eventTimes.start != data._startTime?.toDate().toEventHour() || eventTimes.end != data._endTime?.toDate().toEventHour()) {
			typeView?.backgroundColor = UIUtils.planningDarkOrangeColor()
		}
		
		changeImageToDisplay(data, imageView: statusImageView)
		statusImageView.imageAtIndexPath = indexPath
		
		
		let singleTap = UITapGestureRecognizer(target: self, action:"actionOnImageView:")
		singleTap.numberOfTapsRequired = 1
		
		statusImageView.userInteractionEnabled = true
		statusImageView.addGestureRecognizer(singleTap)
		
		setActionsOnCell(cell, indexPath :indexPath)
		cell.selectionStyle = .None
		
		return cell
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let date = _tableViewData[section].0
		
		return "  " + date.shortToDate().toTitleString()
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	
	func setActionsOnCell(cell :MGSwipeTableCell, indexPath :NSIndexPath) {
		
		let createEvent = MGSwipeButton(title: NSLocalizedString("AddInCalendar", comment: ""), icon: nil, backgroundColor: UIUtils.planningBlueColor(), callback: { (sender: MGSwipeTableCell!) -> Bool in
			
			let calman = CalendarManager()
			calman.createEvent(self._tableViewData[indexPath.section].1[indexPath.row]) { (isOk :Bool, mess :String) in
				
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
		
		if (data._eventType == "rdv") {
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
		let tapLocation = sender.locationInView(self._tableView)
		let indexPath = self._tableView.indexPathForRowAtPoint(tapLocation)
		let data = _tableViewData[indexPath!.section].1[indexPath!.row]
		
		
		if (data._eventType == "rdv") {
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
		
		let confirmAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: .Default) { (_) in
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
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
			
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
		
		self._tableView.beginUpdates()
		
		let cell = self._tableView.cellForRowAtIndexPath(indexPath)
		
		MJProgressView.instance.showCellProgress(cell!)
		
		let statusImageView = cell?.viewWithTag(6) as! UIImageView
		
		statusImageView.image = nil
		
		PlanningApiCalls.getSpecialEvent(event) { (isOk :Bool, pl :Planning?, mess :String) in
			
			if (!isOk)
			{
				self.showMessage(mess)
			}
			else {
				self._tableViewData[indexPath.section].1[indexPath.row] = pl!
				
				self._tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
				self._tableView.endUpdates()
			}
			
			self._tableView.endUpdates()
			MJProgressView.instance.hideProgress()
		}
		
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let data = _tableViewData[indexPath.section].1[indexPath.row]
		MJProgressView.instance.showProgress(self.view, white: false)
		_tableView.userInteractionEnabled = false
		_tableView.scrollEnabled = false
		if (data._eventType != "rdv") {
			
			PlanningApiCalls.getStudentsRegistered(data) { (isOk :Bool, res :[RegisteredStudent]?, mess :String) in
				MJProgressView.instance.hideProgress()
				self._tableView.userInteractionEnabled = true
				self._tableView.scrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					self._registeredStudentToSend = res!
					self.performSegueWithIdentifier("showStudentsRegistered", sender: self)
				}
			}
		}
		else {
			PlanningApiCalls.getEventDetails(data) { (isOk :Bool, resp :AppointmentEvent?, mess :String) in
				MJProgressView.instance.hideProgress()
				self._tableView.userInteractionEnabled = true
				self._tableView.scrollEnabled = true
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					resp?._eventName = data._actiTitle!
					self._appointmentsToSend = resp!
					self.performSegueWithIdentifier("appointmentDetailSegue", sender: self)
				}
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "showStudentsRegistered") {
			let vc = segue.destinationViewController as! StudentRegisteredViewController
			vc._data = _registeredStudentToSend!
		}
		else if (segue.identifier == "appointmentDetailSegue") {
			let vc = segue.destinationViewController as! AppointmentDetailViewController
			vc._appointment = _appointmentsToSend!
		}
	}
	
	func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
		
		if (direction == .RightToLeft) {
			return _swipeAllowed!
		}
		return false
	}
	
	@IBAction func selectSemestersButtonClicked(sender :AnyObject) {
		_savedSemesters = ApplicationManager.sharedInstance._planningSemesters
		performSegueWithIdentifier("selectSemestersSegue", sender: self)
	}
}
