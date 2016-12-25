//
//  StudentRegisteredViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class StudentRegisteredViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var data = [RegisteredStudent]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = NSLocalizedString("Registered", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		return data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")
		
		let login = cell?.viewWithTag(1) as! UILabel
		let status = cell?.viewWithTag(2) as! UILabel
		
		login.text = data[(indexPath as NSIndexPath).row].login
		status.text = data[(indexPath as NSIndexPath).row].status
		
		if (data[(indexPath as NSIndexPath).row].login == ApplicationManager.sharedInstance.user?.login) {
			login.textColor = UIColor.red
			status.textColor = UIColor.red
		} else {
			login.textColor = UIColor.black
			status.textColor = UIColor.black
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
