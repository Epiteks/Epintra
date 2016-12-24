////
////  ModuleDetailsViewController.swift
////  IntraEpitech
////
////  Created by Maxime Junger on 01/02/16.
////  Copyright © 2016 Maxime Junger. All rights reserved.
////
//
//import UIKit
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}
//
//
//class ModuleDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//	
//	var module :Module?
//	
//	@IBOutlet weak var remainingTime: UILabel!
//	@IBOutlet weak var progressBar: UIProgressView!
//	@IBOutlet weak var tableView: UITableView!
//	@IBOutlet weak var studentsBarButton: UIBarButtonItem!
//	
//	var selectedProj :ProjectDetail?
//	var marksData : [Mark]?
//	var studentsData :[RegisteredStudent]?
//	
//	let typeColors = [
//		"proj" : UIUtils.planningBlueColor(),
//		"rdv" : UIUtils.planningOrangeColor(),
//		"tp" : UIUtils.planningPurpleColor(),
//		"other" : UIUtils.planningBlueColor(),
//		"exam" : UIUtils.planningRedColor(),
//		"class" : UIUtils.planningGreenColor()
//	]
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		
//		// Do any additional setup after loading the view.
//		self.title = module?.title!
//		
//		setTimeLabel()
//		
//		fillProgressView()
//		tableView.separatorInset.left = 0
//		
//		self.studentsBarButton.title = NSLocalizedString("Grades", comment: "")
//	}
//	
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//		// Dispose of any resources that can be recreated.
//	}
//	
//	func setTimeLabel() {
//		let today = Date()
//		let registerLimit = self.module?.endRegister?.shortToDate()
//		let end = self.module?.end!.shortToDate()
//		
//		if ((today as NSDate).earlierDate(registerLimit! as Date) == today) {
//			remainingTime.text = NSLocalizedString("InscriptionEnd", comment: "") + (registerLimit?.toTitleString())!
//		} else if ((today as NSDate).earlierDate(end! as Date) == today) {
//			remainingTime.text = NSLocalizedString("ModuleEnd", comment: "") + (end?.toTitleString())!
//		} else {
//			remainingTime.text = NSLocalizedString("ModuleEndedSince", comment: "") + (end?.toTitleString())!
//		}
//		
//		
//	}
//	
//	func fillProgressView() {
//		
//		let begin = self.module?.begin!.shortToDate()
//		let end = self.module?.end!.shortToDate()
//		let today = Date()
//		
//		let totalTime = end?.timeIntervalSince(begin! as Date)
//		let currentTime = end?.timeIntervalSince(today)
//		
//		let percent = 1 - (currentTime! * 100 / totalTime!) / 100
//		
//		if ((end as NSDate?)?.earlierDate(today) == end) {
//			self.progressBar.setProgress(1.0, animated: true)
//			self.progressBar.progressTintColor = UIUtils.planningRedColor()
//			return
//		}
//		
//		self.progressBar.setProgress(Float(percent), animated: true)
//		
//		if (percent > 0.8) {
//			self.progressBar.progressTintColor = UIUtils.planningOrangeColor()
//		} else {
//			self.progressBar.progressTintColor = UIUtils.planningGreenColor()
//		}
//	}
//	
//	
//	/*
//	// MARK: - Navigation
//	
//	// In a storyboard-based application, you will often want to do a little preparation before navigation
//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//	// Get the new view controller using segue.destinationViewController.
//	// Pass the selected object to the new view controller.
//	}
//	*/
//	
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return 1
//	}
//	
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		
//		if (module != nil) {
//			return (module?.activities.count)!
//		}
//		
//		return 1
//	}
//	
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		
//		let cell = tableView.dequeueReusableCell(withIdentifier: "moduleCell")
//		
//		let titleLabel = cell?.viewWithTag(1) as! UILabel
//		let noteLabel = cell?.viewWithTag(2) as! UILabel
//		let beginLabel = cell?.viewWithTag(3) as! UILabel
//		let endLabel = cell?.viewWithTag(4) as! UILabel
//		let eventType = cell?.viewWithTag(5)
//		
//		titleLabel.text = module?.activities[(indexPath as NSIndexPath).row].actiTitle!
//		
//		let acti = module?.activities[(indexPath as NSIndexPath).row]
//		
//		if (acti!.noteActi != nil) {
//			noteLabel.text = acti!.noteActi!
//		} else {
//			noteLabel.text = ""
//		}
//		
//		beginLabel.text = acti!.beginActi?.toDate().toActiDate()
//		endLabel.text = acti!.endActi?.toDate().toActiDate()
//		
//		eventType?.backgroundColor = typeColors[acti!.typeActiCode!]
//		
//		if (acti!.typeActiCode! == "proj" || acti!.typeActiCode! == "rdv" || acti!.noteActi!.characters.count > 0) {
//			cell?.accessoryType = .disclosureIndicator
//		} else {
//			cell?.accessoryType = .none
//		}
//		
//		
//		
//		return cell!
//	}
//	
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		
//		let acti = module?.activities[(indexPath as NSIndexPath).row]
//		
//		if (!(acti!.typeActiCode! == "proj" || acti!.typeActiCode! == "rdv" || acti!.noteActi?.characters.count > 0)) {
//			return
//		}
//		
//		self.tableView.isUserInteractionEnabled = false
//		
//		MJProgressView.instance.showProgress(self.view, white: false)
//		
//		let proj = module?.activities[(indexPath as NSIndexPath).row]
//		proj?.scolaryear = module?.scolaryear
//		proj?.codeModule = module?.codemodule
//		proj?.codeInstance = module?.codeinstance
//		
//		if (acti?.typeActiCode == "proj") {
//			projectStart(proj)
//		} else {
//			appointmentStart(proj)
//		}
//	}
//	
//	
//	func projectStart(_ proj :Project?) {
//		ProjectsApiCall.getProjectDetails(proj!) { (isOk :Bool, proj :ProjectDetail?, mess :String) in
//			
//			if (!isOk) {
//				ErrorViewer.errorPresent(self, mess: mess) {}
//			} else {
//				ProjectsApiCall.getProjectFiles(proj!) { (isOk :Bool, files :[File]?, mess :String) in
//					
//					if (!isOk) {
//						ErrorViewer.errorPresent(self, mess: mess) {}
//					} else {
//						self.selectedProj = proj!
//						self.selectedProj!.files = files
//						self.performSegue(withIdentifier: "projectDetailSegue", sender: self)
//					}
//					self.tableView.isUserInteractionEnabled = true
//				}
//			}
//			self.tableView.isUserInteractionEnabled = true
//			MJProgressView.instance.hideProgress()
//		}
//	}
//	
//	func appointmentStart(_ proj :Project?) {
//		MarksApiCalls.getProjectMarksForProject(proj!) { (isOk :Bool, resp :[Mark]?, mess :String) in
//			
//			if (!isOk) {
//				ErrorViewer.errorPresent(self, mess: mess) {}
//			} else {
//				self.marksData = resp!
//				self.performSegue(withIdentifier: "allMarksSegue", sender: self)
//			}
//			self.tableView.isUserInteractionEnabled = true
//			MJProgressView.instance.hideProgress()
//		}
//	}
//	
//	@IBAction func registeredButtonClicked(_ sender :AnyObject) {
//		
//		MJProgressView.instance.showProgress(self.view, white: false)
//		studentsBarButton.isEnabled = false
//		ModulesApiCalls.getRegistered(self.module!) { (isOk :Bool, resp :[RegisteredStudent]?, mess :String) in
//			self.studentsBarButton.isEnabled = true
//			if (!isOk) {
//				ErrorViewer.errorPresent(self, mess: mess) {}
//			} else {
//				self.studentsData = resp!
//				self.performSegue(withIdentifier: "allRegisteredSegue", sender: self)
//			}
//			MJProgressView.instance.hideProgress()
//		}
//		
//	}
//	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if (segue.identifier == "projectDetailSegue") {
//			let vc = segue.destination as! ProjectsDetailsViewController
//			vc.project = selectedProj
//			vc.marksAllowed = true
//		} else if (segue.identifier == "allMarksSegue") {
//			let vc = segue.destination as! ProjectMarksViewController
//			vc.marks = marksData
//		} else if (segue.identifier == "allRegisteredSegue") {
//			let vc = segue.destination as! RegisteredStudentsViewController
//			vc.students = studentsData
//		}
//	}
//	
//}
