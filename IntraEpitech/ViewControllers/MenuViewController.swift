//
//  MenuViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 18/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var _tableView: UITableView!
	
	let _menuItems = [
		["Home", "homeSegue"],
		["Planning", "planningSegue"],
		["Profile", "profileSegue"],
		["Modules", "modulesSegue"],
		["Projects", "projectsSegue"],
		["Marks", "marksSegue"],
		["Settings", "settingsSegue"],
		]
	
	var _screenHeight :CGFloat = 0.0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_screenHeight = UIScreen.mainScreen().bounds.height
		
		
		_tableView.backgroundColor = UIUtils.backgroundColor()
		_tableView.separatorStyle = .None
		
		_tableView.reloadData()
		
		self.revealViewController().delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
	}
	
	override func viewWillDisappear(animated: Bool) {
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _menuItems.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("menuCell")!
		
		let itemName = cell.viewWithTag(1) as! UILabel
		let itemImage = cell.viewWithTag(2) as! UIImageView
		
		cell.backgroundColor = UIUtils.backgroundColor()
		
		let selected = UIView()
		selected.backgroundColor = UIUtils.lightBackgroundColor()
		
		cell.selectedBackgroundView = selected
		
		if (indexPath.row > 0) {
			let separatorLineView = UIView(frame: CGRectMake(0, 0, 320, 1))
			separatorLineView.backgroundColor = UIUtils.lightBackgroundColor()
			cell.contentView.addSubview(separatorLineView)
		}
		if (indexPath.row < _menuItems.count - 1) {
			let separatorLineView = UIView(frame: CGRectMake(0, tableView.rectForRowAtIndexPath(indexPath).height - 0.5, 320, 1))
			separatorLineView.backgroundColor = UIUtils.lightBackgroundColor()
			cell.contentView.addSubview(separatorLineView)
		}
		
		let item = _menuItems[indexPath.row]
		
		
		itemName.text =  NSLocalizedString(item[0], comment: "")
		
		itemImage.image = UIImage(named: item[0] )
		
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return (_screenHeight / CGFloat(_menuItems.count))
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.userInteractionEnabled = false
		
		performSegueWithIdentifier(_menuItems[indexPath.row][1], sender: self)
	}
	
	func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
		
	}
	
	func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
		
		let frontVC = revealController.frontViewController as! CustomNavigationController
		let subVC = frontVC.viewControllers
		
		if (revealController.frontViewController.title == NSLocalizedString("Home", comment: "")) {
			
			let goodVC = subVC[0] as! HomeViewController
			
			if (position == .Right) {
				goodVC._alertTableView.scrollEnabled = false
			} else {
				goodVC._alertTableView.scrollEnabled = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Planning", comment: "")) {
			
			let goodVC = subVC[0] as! PlanningViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._calendar.userInteractionEnabled = false
				goodVC._swipeAllowed = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._calendar.userInteractionEnabled = true
				goodVC._swipeAllowed = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Profile", comment: "")) {
			
			let goodVC = subVC[0] as! ProfileViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._tableView.userInteractionEnabled = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._tableView.userInteractionEnabled = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Modules", comment: "")) {
			
			let goodVC = subVC[0] as! ModulesViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._tableView.userInteractionEnabled = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._tableView.userInteractionEnabled = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Projects", comment: "")) {
			
			let goodVC = subVC[0] as! ProjectsViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._tableView.userInteractionEnabled = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._tableView.userInteractionEnabled = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Marks", comment: "")) {
			
			let goodVC = subVC[0] as! MarksViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._tableView.userInteractionEnabled = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._tableView.userInteractionEnabled = true
			}
		} else if (revealController.frontViewController.title == NSLocalizedString("Settings", comment: "")) {
			
			let goodVC = subVC[0] as! SettingsViewController
			
			if (position == .Right) {
				goodVC._tableView.scrollEnabled = false
				goodVC._tableView.userInteractionEnabled = false
			} else {
				goodVC._tableView.scrollEnabled = true
				goodVC._tableView.userInteractionEnabled = true
			}
		}
		
		_tableView.userInteractionEnabled = true
	}
}
