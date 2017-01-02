//
//  AppointmentDetailViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
fileprivate func < <T:  Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

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
	
	func setAppointments(_ app: inout AppointmentEvent) {
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return appointments.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return appointments[section].date!.toEventHour()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		if (appointments[(indexPath as NSIndexPath).section].master == nil && appointment.canRegister()) {// appointments[indexPath.section].master == nil && appointment.groupId != "") {
			cell = createRegisterCell()
		} else if (appointments[(indexPath as NSIndexPath).section].master == nil && !appointment.canRegister()) {
			cell = UITableViewCell()
			cell.selectionStyle = .none
		} else if (appointments[(indexPath as NSIndexPath).section].title?.characters.count == 0) {
			cell = createFollowUpCell(indexPath)
		} else {
			cell = createGroupCell(indexPath)
		}
		
		return cell
	}
	
	func createFollowUpCell(_ indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "followUpCell")!
		
		let scrollView = cell.viewWithTag(2) as! UIScrollView
		let data = appointments[(indexPath as NSIndexPath).section]
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for i in 0 ..< data.members!.count {
			let nibView = Bundle.main.loadNibNamed("LittleUserView", owner: self, options: nil)?[0] as! UIView
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell")!
		
		let title = cell.viewWithTag(1) as! UILabel
		
		title.text = NSLocalizedString("Register", comment: "")
		title.textColor = UIUtils.backgroundColor
		
		return cell
	}
	
	func createGroupCell(_ indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell")!
		
		let title = cell.viewWithTag(40) as! UILabel
		
		let scrollView = cell.viewWithTag(41) as! UIScrollView
		let data = appointments[(indexPath as NSIndexPath).section]
		
		title.text = data.title!
		
		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}
		
		for i in 0 ..< data.members!.count {
			let nibView = Bundle.main.loadNibNamed("LittleUserView", owner: self, options: nil)?[0] as! UIView
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let data = appointments[(indexPath as NSIndexPath).section]
		if (appointment.canRegister() && data.master == nil) {
			self.tableView.isUserInteractionEnabled = false
			self.tableView.isScrollEnabled = false
			MJProgressView.instance.showProgress(self.view, white: false)
			PlanningApiCalls.subscribeToSlot(appointment, slot: data) { (isOk: Bool, _, mess: String) in
				
				if (!isOk) {
					MJProgressView.instance.hideProgress()
					self.tableView.isUserInteractionEnabled = true
					self.tableView.isScrollEnabled = true
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					let tmp = Planning(appointment: self.appointment)
					tmp.startTime = self.appointment.eventStart?.toAppointmentString()
					tmp.endTime = self.appointment.eventEnd?.toAppointmentString()
					PlanningApiCalls.getEventDetails(tmp) { (isOk: Bool, resp: AppointmentEvent?, mess: String) in
						MJProgressView.instance.hideProgress()
						self.tableView.isUserInteractionEnabled = true
						self.tableView.isScrollEnabled = true
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
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if (appointments[(indexPath as NSIndexPath).section].title! == "" || appointments[(indexPath as NSIndexPath).section].master == nil) {
			return 70
		} else {
			return 95
		}
	}
	
	func actionOnImageView(_ sender: UIGestureRecognizer) {
		let tapLocation = sender.location(in: self.tableView)
		let indexPath = self.tableView.indexPathForRow(at: tapLocation)
		let data = appointments[(indexPath! as NSIndexPath).section]
		
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
					self.tableView.isUserInteractionEnabled = true
					self.tableView.isScrollEnabled = true
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
