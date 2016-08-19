//
//  RegisteredStudentsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 03/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class RegisteredStudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var students :[RegisteredStudent]?
	
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = NSLocalizedString("Grades", comment: "")
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(RegisteredStudentsViewController.backButtonAction(_:))))
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
	
	override func viewDidAppear(animated: Bool) {
		var index :NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
		
		var i = 0
		
		for tmp in students! {
			if (tmp.login == ApplicationManager.sharedInstance.currentLogin!) {
				index = NSIndexPath(forRow: i, inSection: 0)
				break
			}
			i += 1
		}
		tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: true)
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
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (students?.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")
		
		let studentNameLabel = cell?.viewWithTag(1) as! UILabel
		let gradeLabel = cell?.viewWithTag(2) as! UILabel
		
		studentNameLabel.text = students![indexPath.row].login
		gradeLabel.text = students![indexPath.row].grade
		
		if (students![indexPath.row].login == ApplicationManager.sharedInstance.currentLogin) {
			studentNameLabel.textColor = UIColor.redColor()
			gradeLabel.textColor = UIColor.redColor()
		} else {
			studentNameLabel.textColor = UIColor.blackColor()
			gradeLabel.textColor = UIColor.blackColor()
		}

		
		return cell!
	}
}
