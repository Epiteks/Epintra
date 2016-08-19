//
//  SettingsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

	@IBOutlet weak var menuButton: UIBarButtonItem!

	var products: [SKProduct]!

	let _settingsItems = [
		["DefaultCalendar"],
		["DownloadOnData"],
		["ThirdParty", "BugQuestion"],
		["Disconnect"]
	]
	@IBOutlet weak var _tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

				//self.title = NSLocalizedString("Settings", comment: "")
//self.navigationItem.backBarButtonItem?.tintColor = UIColor.redColor()

	}

	override func awakeFromNib() {
		self.title = NSLocalizedString("Settings", comment: "")
	}

	//	func productTest() {
	//		products = [SKProduct]()
	//
	//		IntraProduct.store.requestProductsWithCompletionHandler { success, products in
	//			if success {
	//				self.products = products
	//				for tmp in products {
	//					print(tmp.productIdentifier)
	//					print(tmp.price)
	//				}
	//			}
	//			print("hello")
	//
	//			for tmp in self.products {
	//				print(tmp.productIdentifier)
	//				print(tmp.price)
	//			}
	//		}
	//	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(animated: Bool) {
		self._tableView.reloadData()
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return _settingsItems.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _settingsItems[section].count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		var cell = UITableViewCell()

		cell.accessoryType = .None

		if (_settingsItems[indexPath.section][indexPath.row] == "Disconnect") {
			cell.textLabel?.textColor = UIColor.redColor()
			cell.textLabel?.text = NSLocalizedString(_settingsItems[indexPath.section][indexPath.row], comment: "")
		} else if (_settingsItems[indexPath.section][indexPath.row] == "DownloadOnData") {
			cell = tableView.dequeueReusableCellWithIdentifier("switchCell")!
			let uiswitch = cell.viewWithTag(1) as! UISwitch
			let label = cell.viewWithTag(2) as! UILabel
			uiswitch.onTintColor = UIUtils.backgroundColor()
			uiswitch.on = ApplicationManager.sharedInstance.canDownload!
			uiswitch.addTarget(self, action: #selector(SettingsViewController.switchClicked(_:)), forControlEvents: .ValueChanged)
			label.text = NSLocalizedString(_settingsItems[indexPath.section][indexPath.row], comment: "")
		} else if (_settingsItems[indexPath.section][indexPath.row] == "DefaultCalendar") {

			if let cal = ApplicationManager.sharedInstance.defaultCalendar {
				cell = tableView.dequeueReusableCellWithIdentifier("CalendarCell")!
				let titleLabel = cell.viewWithTag(1) as! UILabel
				let calendarName = cell.viewWithTag(2) as! UILabel
				titleLabel.text = NSLocalizedString("DefaultCalendar", comment: "")
				calendarName.text = cal
			} else {
				cell.accessoryType = .DisclosureIndicator
				cell.textLabel?.text = NSLocalizedString("DefaultCalendar", comment: "")
			}

		} else if (_settingsItems[indexPath.section][indexPath.row] == "ThirdParty") {
			cell.accessoryType = .DisclosureIndicator
			cell.textLabel?.text = NSLocalizedString("ThirdParty", comment: "")
		} else if (_settingsItems[indexPath.section][indexPath.row] == "BugQuestion") {
			cell.textLabel?.text = NSLocalizedString("BugQuestion", comment: "")
		}

		return cell
	}

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		if (_settingsItems[indexPath.section][indexPath.row] == "Disconnect") {
			disconnectAction()
		} else if (_settingsItems[indexPath.section][indexPath.row] == "DefaultCalendar") {

			performSegueWithIdentifier("SelectCalendarSegue", sender: self)

		} else if (_settingsItems[indexPath.section][indexPath.row] == "ThirdParty") {
			showThirdParty()
		} else if (_settingsItems[indexPath.section][indexPath.row] == "BugQuestion") {
			sendEmail()
		} else {
			//productTest()
		}



	}

	func disconnectAction() {

		let confirmationMenu = UIAlertController(title: nil, message: NSLocalizedString("WantToDisconnect", comment: ""), preferredStyle: .ActionSheet)

		let disconnect = UIAlertAction(title: NSLocalizedString("Disconnect", comment: ""), style: .Destructive, handler: {
			(alert: UIAlertAction!) -> Void in

			UserPreferences.deleteData()

			let storyboard = UIStoryboard(name: "ConnexionStoryboard", bundle: nil)
			let vc = storyboard.instantiateInitialViewController()
			self.presentViewController(vc!, animated: true, completion: nil)
		})

		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
			(alert: UIAlertAction!) -> Void in
			print("Cancelled")
		})

		confirmationMenu.addAction(disconnect)
		confirmationMenu.addAction(cancelAction)

		self.presentViewController(confirmationMenu, animated: true, completion: nil)
	}

	func switchClicked(sender: UISwitch?) {
		print(sender?.on)
		ApplicationManager.sharedInstance.canDownload = sender!.on
		UserPreferences.saveWantToDownloadImage(sender!.on)
	}

	func sendEmail() {

		if (MFMailComposeViewController.canSendMail()) {
			let mailComposerVC = MFMailComposeViewController()
			mailComposerVC.mailComposeDelegate = self
			mailComposerVC.setToRecipients(["maxime.junger@epitech.eu"])
			mailComposerVC.setSubject("IntraEpitech")
			mailComposerVC.setMessageBody(SystemUtils.getAllMailData(), isHTML: false)
			self.presentViewController(mailComposerVC, animated: true, completion: nil)
		}

	}

	func showThirdParty() {
		self.performSegueWithIdentifier("webViewSegue", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "webViewSegue") {
			let vc: WebViewViewController = segue.destinationViewController as! WebViewViewController
			vc.fileName = "thirdParty"
			vc.title = NSLocalizedString("ThirdParty", comment: "")
			vc.isUrl = false
		}
	}

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}
