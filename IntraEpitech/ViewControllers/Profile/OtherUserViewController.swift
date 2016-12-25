//
//  OtherUserViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 07/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import MessageUI
import AddressBookUI
import Contacts
import ContactsUI
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class OtherUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, CNContactViewControllerDelegate {
	
	@IBOutlet weak var profileViewContainer: UIView!
	
	var profileImageView :UIImageView!
	var creditsTitleLabel :UILabel!
	var creditsLabel :UILabel!
	var spicesLabel :UILabel!
	var logLabel :UILabel!
	var gpaTitleLabel :UILabel!
	var gpaLabel :UILabel!
	var	gpaTypeLabel :UILabel!
	var currentUser :User?
	
	var isModuleDownloading :Bool?
	var isMarksDownloading :Bool?
	var isFlagsDownloading :Bool?
	
	var flags :[Flags]?
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	@IBOutlet weak var actionButton: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		segmentedControl.setTitle(NSLocalizedString("Modules", comment: ""), forSegmentAt: 0)
		segmentedControl.setTitle(NSLocalizedString("Marks", comment: ""), forSegmentAt: 1)
		segmentedControl.setTitle(NSLocalizedString("Flags", comment: ""), forSegmentAt: 2)
		loadProfileView()
		setUIElements()
		self.title = currentUser?.login
		
		self.segmentedControl.tintColor = UIUtils.backgroundColor()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		isMarksDownloading = true
		MarksApiCalls.getMarksFor(user: self.currentUser!.login!) { (isOk :Bool, resp :[Mark]?, mess :String) in
			self.isMarksDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			} else {
				self.currentUser?.marks = resp
				if (self.segmentedControl.selectedSegmentIndex == 1) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
		self.isModuleDownloading = true
		ModulesApiCalls.getRegisteredModulesFor(user: self.currentUser!.login!) { (isOk :Bool, resp :[Module]?, mess :String) in
			self.isModuleDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
				MJProgressView.instance.hideProgress()
			} else {
				self.currentUser?.modules = resp!
				if (self.segmentedControl.selectedSegmentIndex == 0) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
		self.isFlagsDownloading = true
		/*UserApiCalls.getUserFlags(self.currentUser!.login!) { (isOk :Bool, resp :[Flags]?, mess :String) in
			self.isFlagsDownloading = false
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.flags = resp!
				if (self.segmentedControl.selectedSegmentIndex == 2) {
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}*/
	}
	
	override func viewDidAppear(_ animated: Bool) {
		MJProgressView.instance.showProgress(self.tableView, white: false)
		self.profileImageView.image = UIImage(named: "userProfile")
		ImageDownloader.downloadFrom(link: (currentUser?.imageUrl)!) {_ in 
			if let img = ApplicationManager.sharedInstance.downloadedImages![self.currentUser!.imageUrl!] {
				self.profileImageView.image = img
				self.profileImageView.cropToSquare()
			}
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func loadProfileView() {
		let nibView = Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)?[0] as! UIView
		profileViewContainer.addSubview(nibView)
		
		profileImageView = nibView.viewWithTag(1) as? UIImageView
		creditsTitleLabel = nibView.viewWithTag(2) as? UILabel!
		creditsLabel = nibView.viewWithTag(3) as? UILabel!
		spicesLabel = nibView.viewWithTag(4) as? UILabel!
		logLabel = nibView.viewWithTag(5) as? UILabel!
		gpaTitleLabel = nibView.viewWithTag(6) as? UILabel!
		gpaLabel = nibView.viewWithTag(7) as? UILabel!
		gpaTypeLabel = nibView.viewWithTag(8) as? UILabel!
	}
	
	func setUIElements() {
		creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
		creditsLabel.text = String(currentUser!.credits!)
		spicesLabel.text =  currentUser!.spices!.currentSpices + " " + NSLocalizedString("spices", comment: "")
		logLabel.text = "Log : " + String(currentUser!.log!.timeActive)
		logLabel.textColor = currentUser?.log?.getColor()
		
		let gpa = currentUser?.getLatestGPA()
		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		gpaLabel.text = gpa?.value
		gpaTypeLabel.text = gpa?.cycle
		profileImageView.cropToSquare()
		profileImageView.toCircle()
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	@IBAction func segmentedChanged(_ sender: UISegmentedControl) {
		
		if (sender.selectedSegmentIndex == 0 && self.isModuleDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else if (sender.selectedSegmentIndex == 1 && self.isMarksDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else if (sender.selectedSegmentIndex == 2 && self.isFlagsDownloading == true) {
			MJProgressView.instance.showProgress(self.tableView, white: false)
		} else {
			MJProgressView.instance.hideProgress()
		}
		
		self.tableView.reloadData()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if (segmentedControl.selectedSegmentIndex == 2) {
			return (flags?.count)!
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if ((currentUser?.modules == nil && segmentedControl.selectedSegmentIndex == 0)
			|| (currentUser?.marks == nil && segmentedControl.selectedSegmentIndex == 1)
			|| (flags == nil && segmentedControl.selectedSegmentIndex == 2)) {
			self.tableView.separatorStyle = .none
			return 0
		}
		self.tableView.separatorStyle = .singleLine
		switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			return (currentUser?.modules?.count)!
		case 1:
			return (currentUser?.marks?.count)!
		case 2:
			let cnt = flags![section].modules.count
			return (cnt == 0 ? 1 : cnt)
		default:
			return 0
		}
		
		//		return (segmentedControl.selectedSegmentIndex == 0 ? currentUser?.modules!.count : currentUser?.marks!.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCell(withIdentifier: "marksCell")
		
		if (segmentedControl.selectedSegmentIndex == 0) {
			cell = tableView.dequeueReusableCell(withIdentifier: "moduleCell")
			
			let titleLabel = cell?.viewWithTag(1) as! UILabel
			let creditsLabel = cell?.viewWithTag(2) as! UILabel
			let gradeLabel = cell?.viewWithTag(3) as! UILabel
			
			let module = currentUser?.modules![(indexPath as NSIndexPath).row]
			
			creditsLabel.text = NSLocalizedString("AvailableCredits", comment: "") + module!.credits!
			if (module!.grade != nil) {
				gradeLabel.text = module!.grade!
			}
			titleLabel.text = module!.title!
		} else if (segmentedControl.selectedSegmentIndex == 1) {
			
			cell = tableView.dequeueReusableCell(withIdentifier: "marksCell")
			
			let actiTitle = cell?.viewWithTag(1) as! UILabel
			let moduleTitle = cell?.viewWithTag(2) as! UILabel
			let markLabel = cell?.viewWithTag(3) as! UILabel
			
			let mark = currentUser?.marks![(indexPath as NSIndexPath).row]
			
			actiTitle.text = mark?.title!
			moduleTitle.text = mark?.titleModule!
			markLabel.text = mark?.finalNote!
		} else {
			if (flags![(indexPath as NSIndexPath).section].modules.count > 0) {
				cell = tableView.dequeueReusableCell(withIdentifier: "flagCell")!
				let titleLabel = cell!.viewWithTag(1) as! UILabel
				let gradeLabel = cell!.viewWithTag(2) as! UILabel
				let module = flags![(indexPath as NSIndexPath).section].modules[(indexPath as NSIndexPath).row]
				titleLabel.text = module.title
				gradeLabel.text = module.grade
			} else if ((indexPath as NSIndexPath).section > 0 && flags![(indexPath as NSIndexPath).section].modules.count == 0) {
				cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell")!
				let titleLabel = cell!.viewWithTag(1) as! UILabel
				titleLabel.text = NSLocalizedString("NoFlag", comment: "")
			}
			
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	@IBAction func actionButtonClicked(_ sender: AnyObject) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			
		}
		alertController.addAction(cancelAction)
		
		if (currentUser?.phone != nil && currentUser?.phone?.characters.count > 0) {
			
			let callAction = UIAlertAction(title: NSLocalizedString("Call", comment: "") + " " + (currentUser?.phone!)!, style: .default) { (_) in
				
				let nbr = self.currentUser?.phone!.replacingOccurrences(of: " ", with: "")
				
				let numberToCall = "tel://" + nbr!
				UIApplication.shared.openURL(URL(string: numberToCall)!)
			}
			alertController.addAction(callAction)
		}
		
		let emailAction = UIAlertAction(title: NSLocalizedString("Email", comment: ""), style: .default) { (_) in
			
			if (MFMailComposeViewController.canSendMail()) {
				let mailComposerVC = MFMailComposeViewController()
				mailComposerVC.mailComposeDelegate = self
				mailComposerVC.setToRecipients([(self.currentUser?.internalEmail!)!])
				self.present(mailComposerVC, animated: true, completion: nil)
			}
			
		}
		alertController.addAction(emailAction)
		
		self.present(alertController, animated: true) {
		}
		
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if segmentedControl.selectedSegmentIndex != 2 {
			return nil
		}
		
		var str = ""
		
		switch section {
		case 0 : str = "Medals"
			break
		case 1 : str = "Remarkables"
			break
		case 2 : str = "Difficulty"
			break
		case 3 : str = "Ghost"
			break
		default: str = ""
			break
		}
		return NSLocalizedString(str, comment: "")
	}
}
