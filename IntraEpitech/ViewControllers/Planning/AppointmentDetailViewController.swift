//
//  AppointmentDetailViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var appointment: AppointmentEvent!
	var appointments = [Appointment]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		appointments = appointment.slots!
		
		// Do any additional setup after loading the view.
		self.title = appointment.eventName!
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setAppointments(inout app: AppointmentEvent) {
		appointment = app
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
		return appointments.count
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return appointments[section].date!.toEventHour()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		if (appointments[indexPath.section].master == nil && appointment.canRegister()) {// appointments[indexPath.section].master == nil && appointment.groupId != "") {
			cell = createRegisterCell()
		} else if (appointments[indexPath.section].master == nil && !appointment.canRegister()) {
			cell = UITableViewCell()
			cell.selectionStyle = .None
		} else if (appointments[indexPath.section].title?.characters.count == 0) {
			cell = createFollowUpCell(indexPath)
		} else {
			cell = createGroupCell(indexPath)
		}
		
		return cell
	}
	
	func createFollowUpCell(indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("followUpCell")!
		
		let scrollView = cell.viewWithTag(2) as! UIScrollView
		let data = appointments[indexPath.section]
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for (var i = 0; i < data.members?.count; i += 1) {
			let nibView = NSBundle.mainBundle().loadNibNamed("LittleUserView", owner: self, options: nil)[0] as! UIView
			var profileViewFrame = nibView.frame
			profileViewFrame.origin.x = profileViewFrame.size.width * CGFloat(i)
			nibView.frame = profileViewFrame
			
			let login = nibView.viewWithTag(2) as! UILabel
			let userProfileImage = nibView.viewWithTag(1) as! UIImageView
			
			userProfileImage.cropToSquare()
			userProfileImage.toCircle()
			
			nibView.tag = indexPath.section * 100 + i
			
			if (data.members![i].imageURL.characters.count > 0) {
				if let img = ApplicationManager.sharedInstance.downloadedImages![data.members![i].imageURL] {
					userProfileImage.image = img
					userProfileImage.cropToSquare()
				} else {
					ImageDownloader.downloadFromCallback(link: data.members![i].imageURL) { (link: String) in
						if let img = ApplicationManager.sharedInstance.downloadedImages![link] {
							userProfileImage.image = img
							userProfileImage.cropToSquare()
							userProfileImage.toCircle()
						}
						
					}
				}
			}
			
			
			login.text = data.members![i].login
			
			scrollView.contentSize.width = nibView.frame.origin.x + nibView.frame.size.width
			scrollView.addSubview(nibView)
			
		}
		return cell
		
	}
	
	func createRegisterCell() -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("registerCell")!
		
		let title = cell.viewWithTag(1) as! UILabel
		
		title.text = NSLocalizedString("Register", comment: "")
		title.textColor = UIUtils.backgroundColor()
		
		return cell
	}
	
	func createGroupCell(indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("groupCell")!
		
		let title = cell.viewWithTag(40) as! UILabel
		
		let scrollView = cell.viewWithTag(41) as! UIScrollView
		let data = appointments[indexPath.section]
		
		
		title.text = data.title!
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for (var i = 0; i < data.members?.count; i += 1) {
			let nibView = NSBundle.mainBundle().loadNibNamed("LittleUserView", owner: self, options: nil)[0] as! UIView
			var profileViewFrame = nibView.frame
			profileViewFrame.origin.x = profileViewFrame.size.width * CGFloat(i)
			nibView.frame = profileViewFrame
			
			let login = nibView.viewWithTag(2) as! UILabel
			let userProfileImage = nibView.viewWithTag(1) as! UIImageView
			
			userProfileImage.cropToSquare()
			userProfileImage.toCircle()
			
			nibView.tag = indexPath.section * 100 + i
			
			if (data.members![i].imageURL.characters.count > 0) {
				if let img = ApplicationManager.sharedInstance.downloadedImages![data.members![i].imageURL] {
					userProfileImage.image = img
					userProfileImage.cropToSquare()
				} else {
					ImageDownloader.downloadFromCallback(link: data.members![i].imageURL) { (link: String) in
						if let img = ApplicationManager.sharedInstance.downloadedImages![link] {
							userProfileImage.image = img
							userProfileImage.cropToSquare()
							userProfileImage.toCircle()
						}
						
					}
				}
			}
			
			
			login.text = data.members![i].login
			
			scrollView.contentSize.width = nibView.frame.origin.x + nibView.frame.size.width
			scrollView.addSubview(nibView)
			
		}
		return cell
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		let data = appointments[indexPath.section]
		if (appointment.canRegister() && data.master == nil) {
			self.tableView.userInteractionEnabled = false
			self.tableView.scrollEnabled = false
			MJProgressView.instance.showProgress(self.view, white: false)
			PlanningApiCalls.subscribeToSlot(appointment, slot: data) { (isOk: Bool, _, mess: String) in
				
				if (!isOk) {
					MJProgressView.instance.hideProgress()
					self.tableView.userInteractionEnabled = true
					self.tableView.scrollEnabled = true
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					let tmp = Planning(appointment: self.appointment)
					tmp.startTime = self.appointment.eventStart?.toAppointmentString()
					tmp.endTime = self.appointment.eventEnd?.toAppointmentString()
					PlanningApiCalls.getEventDetails(tmp) { (isOk: Bool, resp: AppointmentEvent?, mess: String) in
						MJProgressView.instance.hideProgress()
						self.tableView.userInteractionEnabled = true
						self.tableView.scrollEnabled = true
						if (!isOk) {
							ErrorViewer.errorPresent(self, mess: mess) {}
						} else {
							//self.appointment = resp!
							self.appointment.registered = true
							self.appointment.slots = resp!.slots
							self.appointments = self.appointment.slots!
							self.tableView.reloadData()
						}
					}
				}
				
			}
			
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if (appointments[indexPath.section].title! == "" || appointments[indexPath.section].master == nil) {
			return 70
		} else {
			return 95
		}
	}
	
	func actionOnImageView(sender: UIGestureRecognizer) {
		let tapLocation = sender.locationInView(self.tableView)
		let indexPath = self.tableView.indexPathForRowAtPoint(tapLocation)
		let data = appointments[indexPath!.section]
		
		print(data.master?.login)
		MJProgressView.instance.showProgress(self.view, white: false)
		PlanningApiCalls.unsubscribeToSlot(self.appointment, slot: data) { (isOk: Bool, _, mess: String) in
			
			if (!isOk) {
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				let tmp = Planning(appointment: self.appointment)
				tmp.startTime = self.appointment.eventStart?.toAppointmentString()
				tmp.endTime = self.appointment.eventEnd?.toAppointmentString()
				PlanningApiCalls.getEventDetails(tmp) { (isOk: Bool, resp: AppointmentEvent?, mess: String) in
					MJProgressView.instance.hideProgress()
					self.tableView.userInteractionEnabled = true
					self.tableView.scrollEnabled = true
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					} else {
						self.appointment = resp!
						self.appointments = self.appointment.slots!
						self.tableView.reloadData()
					}
				}
			}
			
		}
		
	}}
