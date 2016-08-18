//
//  AppointmentDetailViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var _tableView: UITableView!
	
	var _appointment : AppointmentEvent!
	var _appointments = [Appointment]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_appointments = _appointment._slots!
		
		// Do any additional setup after loading the view.
		self.title = _appointment._eventName!
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(AppointmentDetailViewController.backButtonAction(_:))))
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
	
	func setAppointments(inout app :AppointmentEvent) {
		_appointment = app
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
		return _appointments.count
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return _appointments[section]._date!.toEventHour()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell :UITableViewCell!
		
		if (_appointments[indexPath.section]._master == nil && _appointment.canRegister()) {// _appointments[indexPath.section]._master == nil && _appointment._groupId != "") {
			cell = createRegisterCell()
		}
		else if (_appointments[indexPath.section]._master == nil && !_appointment.canRegister()) {
			cell = UITableViewCell()
			cell.selectionStyle = .None
		}
		else if (_appointments[indexPath.section]._title?.characters.count == 0) {
			cell = createFollowUpCell(indexPath)
		}
		else {
			cell = createGroupCell(indexPath)
		}
		
		return cell
	}
	
	func createFollowUpCell(indexPath :NSIndexPath) -> UITableViewCell {
		
		let cell = _tableView.dequeueReusableCellWithIdentifier("followUpCell")!
		
		let scrollView = cell.viewWithTag(2) as! UIScrollView
		let data = _appointments[indexPath.section]
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for (var i = 0; i < data._members?.count; i += 1) {
			let nibView = NSBundle.mainBundle().loadNibNamed("LittleUserView", owner: self, options: nil)[0] as! UIView
			var profileViewFrame = nibView.frame
			profileViewFrame.origin.x = profileViewFrame.size.width * CGFloat(i)
			nibView.frame = profileViewFrame
			
			let login = nibView.viewWithTag(2) as! UILabel
			let userProfileImage = nibView.viewWithTag(1) as! UIImageView
			
			userProfileImage.cropToSquare()
			userProfileImage.toCircle()
			
			nibView.tag = indexPath.section * 100 + i
			
			if (data._members![i]._imageURL.characters.count > 0) {
				if let img = ApplicationManager.sharedInstance._downloadedImages![data._members![i]._imageURL]
				{
					userProfileImage.image = img
					userProfileImage.cropToSquare()
				}
				else {
					ImageDownloader.downloadFromCallback(link: data._members![i]._imageURL) { (link :String) in
						if let img = ApplicationManager.sharedInstance._downloadedImages![link]
						{
							userProfileImage.image = img
							userProfileImage.cropToSquare()
							userProfileImage.toCircle()
						}
						
					}
				}
			}
			
			
			login.text = data._members![i]._login
			
			scrollView.contentSize.width = nibView.frame.origin.x + nibView.frame.size.width
			scrollView.addSubview(nibView)
			
		}
		return cell
		
	}
	
	func createRegisterCell() -> UITableViewCell {
		
		let cell = _tableView.dequeueReusableCellWithIdentifier("registerCell")!
		
		let title = cell.viewWithTag(1) as! UILabel
		
		title.text = NSLocalizedString("Register", comment: "")
		title.textColor = UIUtils.backgroundColor()
		
		return cell
	}
	
	func createGroupCell(indexPath :NSIndexPath) -> UITableViewCell {
		
		let cell = _tableView.dequeueReusableCellWithIdentifier("groupCell")!
		
		let title = cell.viewWithTag(40) as! UILabel
		
		let scrollView = cell.viewWithTag(41) as! UIScrollView
		let data = _appointments[indexPath.section]
		
		
		title.text = data._title!
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for (var i = 0; i < data._members?.count; i += 1) {
			let nibView = NSBundle.mainBundle().loadNibNamed("LittleUserView", owner: self, options: nil)[0] as! UIView
			var profileViewFrame = nibView.frame
			profileViewFrame.origin.x = profileViewFrame.size.width * CGFloat(i)
			nibView.frame = profileViewFrame
			
			let login = nibView.viewWithTag(2) as! UILabel
			let userProfileImage = nibView.viewWithTag(1) as! UIImageView
			
			userProfileImage.cropToSquare()
			userProfileImage.toCircle()
			
			nibView.tag = indexPath.section * 100 + i
			
			if (data._members![i]._imageURL.characters.count > 0) {
				if let img = ApplicationManager.sharedInstance._downloadedImages![data._members![i]._imageURL]
				{
					userProfileImage.image = img
					userProfileImage.cropToSquare()
				}
				else {
					ImageDownloader.downloadFromCallback(link: data._members![i]._imageURL) { (link :String) in
						if let img = ApplicationManager.sharedInstance._downloadedImages![link]
						{
							userProfileImage.image = img
							userProfileImage.cropToSquare()
							userProfileImage.toCircle()
						}
						
					}
				}
			}
			
			
			login.text = data._members![i]._login
			
			scrollView.contentSize.width = nibView.frame.origin.x + nibView.frame.size.width
			scrollView.addSubview(nibView)
			
		}
		return cell
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		let data = _appointments[indexPath.section]
		if (_appointment.canRegister() && data._master == nil) {
			self._tableView.userInteractionEnabled = false
			self._tableView.scrollEnabled = false
			MJProgressView.instance.showProgress(self.view, white: false)
			PlanningApiCalls.subscribeToSlot(_appointment, slot: data) { (isOk :Bool, _, mess :String) in
				
				if (!isOk) {
					MJProgressView.instance.hideProgress()
					self._tableView.userInteractionEnabled = true
					self._tableView.scrollEnabled = true
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					let tmp = Planning(appointment: self._appointment)
					tmp._startTime = self._appointment._eventStart?.toAppointmentString()
					tmp._endTime = self._appointment._eventEnd?.toAppointmentString()
					PlanningApiCalls.getEventDetails(tmp) { (isOk :Bool, resp :AppointmentEvent?, mess :String) in
						MJProgressView.instance.hideProgress()
						self._tableView.userInteractionEnabled = true
						self._tableView.scrollEnabled = true
						if (!isOk) {
							ErrorViewer.errorPresent(self, mess: mess) {}
						}
						else {
							//self._appointment = resp!
							self._appointment._registered = true
							self._appointment._slots = resp!._slots
							self._appointments = self._appointment._slots!
							self._tableView.reloadData()
						}
					}
				}
				
			}
			
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if (_appointments[indexPath.section]._title! == "" || _appointments[indexPath.section]._master == nil) {
			return 70
		}
		else {
			return 95
		}
	}
	
	func actionOnImageView(sender :UIGestureRecognizer)
	{
		let tapLocation = sender.locationInView(self._tableView)
		let indexPath = self._tableView.indexPathForRowAtPoint(tapLocation)
		let data = _appointments[indexPath!.section]
		
		print(data._master?._login)
		MJProgressView.instance.showProgress(self.view, white: false)
		PlanningApiCalls.unsubscribeToSlot(self._appointment, slot: data) { (isOk :Bool, _, mess :String) in
			
			if (!isOk) {
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				let tmp = Planning(appointment: self._appointment)
				tmp._startTime = self._appointment._eventStart?.toAppointmentString()
				tmp._endTime = self._appointment._eventEnd?.toAppointmentString()
				PlanningApiCalls.getEventDetails(tmp) { (isOk :Bool, resp :AppointmentEvent?, mess :String) in
					MJProgressView.instance.hideProgress()
					self._tableView.userInteractionEnabled = true
					self._tableView.scrollEnabled = true
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					}
					else {
						self._appointment = resp!
						self._appointments = self._appointment._slots!
						self._tableView.reloadData()
					}
				}
			}
			
		}
		
	}}
