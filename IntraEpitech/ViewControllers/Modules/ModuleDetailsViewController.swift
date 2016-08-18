//
//  ModuleDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModuleDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var _module :Module?
	
	@IBOutlet weak var _remainingTime: UILabel!
	@IBOutlet weak var _progressBar: UIProgressView!
	@IBOutlet weak var _tableView: UITableView!
	@IBOutlet weak var _studentsBarButton: UIBarButtonItem!
	
	var _selectedProj :ProjectDetail?
	var _marksData : [Mark]?
	var _studentsData :[RegisteredStudent]?
	
	let _typeColors = [
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
		self.title = _module?._title!
		
		setTimeLabel()
		
		fillProgressView()
		_tableView.separatorInset.left = 0
		
		self._studentsBarButton.title = NSLocalizedString("Grades", comment: "")
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(ModuleDetailsViewController.backButtonAction(_:))))
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
	
	func setTimeLabel() {
		let today = NSDate()
		let registerLimit = self._module?._endRegister?.shortToDate()
		let end = self._module?._end!.shortToDate()
		
		if (today.earlierDate(registerLimit!) == today) {
			_remainingTime.text = NSLocalizedString("InscriptionEnd", comment: "") + (registerLimit?.toTitleString())!
		}
		else if (today.earlierDate(end!) == today) {
			_remainingTime.text = NSLocalizedString("ModuleEnd", comment: "") + (end?.toTitleString())!
		}
		else {
			_remainingTime.text = NSLocalizedString("ModuleEndedSince", comment: "") + (end?.toTitleString())!
		}
		
		
	}
	
	func fillProgressView() {
		
		let begin = self._module?._begin!.shortToDate()
		let end = self._module?._end!.shortToDate()
		let today = NSDate()
		
		let totalTime = end?.timeIntervalSinceDate(begin!)
		let currentTime = end?.timeIntervalSinceDate(today)
		
		let percent = 1 - (currentTime! * 100 / totalTime!) / 100
		
		if (end?.earlierDate(today) == end) {
			self._progressBar.setProgress(1.0, animated: true)
			self._progressBar.progressTintColor = UIUtils.planningRedColor()
			return
		}
		
		self._progressBar.setProgress(Float(percent), animated: true)
		
		if (percent > 0.8) {
			self._progressBar.progressTintColor = UIUtils.planningOrangeColor()
		}
		else {
			self._progressBar.progressTintColor = UIUtils.planningGreenColor()
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
		
		if (_module != nil) {
			return (_module?._activities.count)!
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
		
		titleLabel.text = _module?._activities[indexPath.row]._actiTitle!
		
		let acti = _module?._activities[indexPath.row]
		
		if (acti!._noteActi != nil) {
			noteLabel.text = acti!._noteActi!
		}
		else {
			noteLabel.text = ""
		}
		
		beginLabel.text = acti!._beginActi?.toDate().toActiDate()
		endLabel.text = acti!._endActi?.toDate().toActiDate()
		
		eventType?.backgroundColor = _typeColors[acti!._typeActiCode!]
		
		if (acti!._typeActiCode! == "proj" || acti!._typeActiCode! == "rdv" || acti!._noteActi!.characters.count > 0) {
			cell?.accessoryType = .DisclosureIndicator
		}
		else {
			cell?.accessoryType = .None
		}
		
		
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let acti = _module?._activities[indexPath.row]
		
		if (!(acti!._typeActiCode! == "proj" || acti!._typeActiCode! == "rdv" || acti!._noteActi?.characters.count > 0)) {
			return
		}
		
		self._tableView.userInteractionEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		let proj = _module?._activities[indexPath.row]
		proj?._scolaryear = _module?._scolaryear
		proj?._codeModule = _module?._codemodule
		proj?._codeInstance = _module?._codeinstance
		
		if (acti?._typeActiCode == "proj") {
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
						self._selectedProj = proj!
						self._selectedProj!._files = files
						self.performSegueWithIdentifier("projectDetailSegue", sender: self)
					}
					self._tableView.userInteractionEnabled = true
				}
			}
			self._tableView.userInteractionEnabled = true
			MJProgressView.instance.hideProgress()
		}
	}
	
	func appointmentStart(proj :Project?) {
		MarksApiCalls.getProjectMarksForProject(proj!) { (isOk :Bool, resp :[Mark]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._marksData = resp!
				self.performSegueWithIdentifier("allMarksSegue", sender: self)
			}
			self._tableView.userInteractionEnabled = true
			MJProgressView.instance.hideProgress()
		}
	}
	
	@IBAction func registeredButtonClicked(sender :AnyObject) {
		
		MJProgressView.instance.showProgress(self.view, white: false)
		_studentsBarButton.enabled = false
		ModulesApiCalls.getRegistered(self._module!) { (isOk :Bool, resp :[RegisteredStudent]?, mess :String) in
			self._studentsBarButton.enabled = true
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._studentsData = resp!
				self.performSegueWithIdentifier("allRegisteredSegue", sender: self)
			}
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "projectDetailSegue") {
			let vc = segue.destinationViewController as! ProjectsDetailsViewController
			vc._project = _selectedProj
			vc._marksAllowed = true
		}
		else if (segue.identifier == "allMarksSegue") {
			let vc = segue.destinationViewController as! ProjectMarksViewController
			vc._marks = _marksData
		}
		else if (segue.identifier == "allRegisteredSegue") {
			let vc = segue.destinationViewController as! RegisteredStudentsViewController
			vc._students = _studentsData
		}
	}
	
}
