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
	}

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		var index :IndexPath = IndexPath(row: 0, section: 0)
		
		var i = 0
		
		for tmp in students! {
			if (tmp.login == ApplicationManager.sharedInstance.currentLogin!) {
				index = IndexPath(row: i, section: 0)
				break
			}
			i += 1
		}
		tableView.scrollToRow(at: index, at: .top, animated: true)
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
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (students?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")
		
		let studentNameLabel = cell?.viewWithTag(1) as! UILabel
		let gradeLabel = cell?.viewWithTag(2) as! UILabel
		
		studentNameLabel.text = students![(indexPath as NSIndexPath).row].login
		gradeLabel.text = students![(indexPath as NSIndexPath).row].grade
		
		if (students![(indexPath as NSIndexPath).row].login == ApplicationManager.sharedInstance.currentLogin) {
			studentNameLabel.textColor = UIColor.red
			gradeLabel.textColor = UIColor.red
		} else {
			studentNameLabel.textColor = UIColor.black
			gradeLabel.textColor = UIColor.black
		}

		
		return cell!
	}
}
