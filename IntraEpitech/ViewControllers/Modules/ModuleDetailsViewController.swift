//
//  ModuleDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModuleDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var module :Module?
	
	@IBOutlet weak var remainingTime: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var studentsBarButton: UIBarButtonItem!
	
	var selectedProj :ProjectDetail?
	var marksData : [Mark]?
	var studentsData :[RegisteredStudent]?
	
	let typeColors = [
		"proj" : UIUtils.planningBlueColor(),
		"rdv" : UIUtils.planningOrangeColor(),
		"tp" : UIUtils.planningPurpleColor(),
		"other" : UIUtils.planningBlueColor(),
		"exam" : UIUtils.planningRedColor(),
		"class" : UIUtils.planningGreenColor()
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = module?.title!
		
		setTimeLabel()
		
		fillProgressView()
		tableView.separatorInset.left = 0
		
		self.studentsBarButton.title = NSLocalizedString("Grades", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setTimeLabel() {
		let today = NSDate()
		let registerLimit = self.module?.endRegister?.shortToDate()
		let end = self.module?.end!.shortToDate()
		
		if (today.earlierDate(registerLimit!) == today) {
			remainingTime.text = NSLocalizedString("InscriptionEnd", comment: "") + (registerLimit?.toTitleString())!
		}
		else if (today.earlierDate(end!) == today) {
			remainingTime.text = NSLocalizedString("ModuleEnd", comment: "") + (end?.toTitleString())!
		}
		else {
			remainingTime.text = NSLocalizedString("ModuleEndedSince", comment: "") + (end?.toTitleString())!
		}
		
		
	}
	
	func fillProgressView() {
		
		let begin = self.module?.begin!.shortToDate()
		let end = self.module?.end!.shortToDate()
		let today = NSDate()
		
		let totalTime = end?.timeIntervalSinceDate(begin!)
		let currentTime = end?.timeIntervalSinceDate(today)
		
		let percent = 1 - (currentTime! * 100 / totalTime!) / 100
		
		if (end?.earlierDate(today) == end) {
			self.progressBar.setProgress(1.0, animated: true)
			self.progressBar.progressTintColor = UIUtils.planningRedColor()
			return
		}
		
		self.progressBar.setProgress(Float(percent), animated: true)
		
		if (percent > 0.8) {
			self.progressBar.progressTintColor = UIUtils.planningOrangeColor()
		}
		else {
			self.progressBar.progressTintColor = UIUtils.planningGreenColor()
		}
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
		
		if (module != nil) {
			return (module?.activities.count)!
		}
		
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("moduleCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let noteLabel = cell?.viewWithTag(2) as! UILabel
		let beginLabel = cell?.viewWithTag(3) as! UILabel
		let endLabel = cell?.viewWithTag(4) as! UILabel
		let eventType = cell?.viewWithTag(5)
		
		titleLabel.text = module?.activities[indexPath.row].actiTitle!
		
		let acti = module?.activities[indexPath.row]
		
		if (acti!.noteActi != nil) {
			noteLabel.text = acti!.noteActi!
		}
		else {
			noteLabel.text = ""
		}
		
		beginLabel.text = acti!.beginActi?.toDate().toActiDate()
		endLabel.text = acti!.endActi?.toDate().toActiDate()
		
		eventType?.backgroundColor = typeColors[acti!.typeActiCode!]
		
		if (acti!.typeActiCode! == "proj" || acti!.typeActiCode! == "rdv" || acti!.noteActi!.characters.count > 0) {
			cell?.accessoryType = .DisclosureIndicator
		}
		else {
			cell?.accessoryType = .None
		}
		
		
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let acti = module?.activities[indexPath.row]
		
		if (!(acti!.typeActiCode! == "proj" || acti!.typeActiCode! == "rdv" || acti!.noteActi?.characters.count > 0)) {
			return
		}
		
		self.tableView.userInteractionEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		let proj = module?.activities[indexPath.row]
		proj?.scolaryear = module?.scolaryear
		proj?.codeModule = module?.codemodule
		proj?.codeInstance = module?.codeinstance
		
		if (acti?.typeActiCode == "proj") {
			projectStart(proj)
		}
		else {
			appointmentStart(proj)
		}
	}
	
	
	func projectStart(proj :Project?) {
		ProjectsApiCall.getProjectDetails(proj!) { (isOk :Bool, proj :ProjectDetail?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				ProjectsApiCall.getProjectFiles(proj!) { (isOk :Bool, files :[File]?, mess :String) in
					
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					}
					else {
						self.selectedProj = proj!
						self.selectedProj!.files = files
						self.performSegueWithIdentifier("projectDetailSegue", sender: self)
					}
					self.tableView.userInteractionEnabled = true
				}
			}
			self.tableView.userInteractionEnabled = true
			MJProgressView.instance.hideProgress()
		}
	}
	
	func appointmentStart(proj :Project?) {
		MarksApiCalls.getProjectMarksForProject(proj!) { (isOk :Bool, resp :[Mark]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self.marksData = resp!
				self.performSegueWithIdentifier("allMarksSegue", sender: self)
			}
			self.tableView.userInteractionEnabled = true
			MJProgressView.instance.hideProgress()
		}
	}
	
	@IBAction func registeredButtonClicked(sender :AnyObject) {
		
		MJProgressView.instance.showProgress(self.view, white: false)
		studentsBarButton.enabled = false
		ModulesApiCalls.getRegistered(self.module!) { (isOk :Bool, resp :[RegisteredStudent]?, mess :String) in
			self.studentsBarButton.enabled = true
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self.studentsData = resp!
				self.performSegueWithIdentifier("allRegisteredSegue", sender: self)
			}
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "projectDetailSegue") {
			let vc = segue.destinationViewController as! ProjectsDetailsViewController
			vc.project = selectedProj
			vc.marksAllowed = true
		}
		else if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc.marks = marksData
		}
		else if (segue.identifier == "allRegisteredSegue") {
			let vc = segue.destinationViewController as! RegisteredStudentsViewController
			vc.students = studentsData
		}
	}
	
}
