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

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    struct SettingsCellData {
        var id: String!
        var view: ((IndexPath, SettingsCellData) -> (UITableViewCell))? = nil
        var handler: (() -> ())? = nil
    }
    
    struct SettingsSectionData {
        var name: String?
        var cells: [SettingsCellData]?
    }
    
    /// Data used to populate the settingsTableView
    var tableData = [SettingsSectionData]()
    
	@IBOutlet weak var settingsTableView: UITableView!
	
    override func viewDidLoad() {
        self.tableData = [
            
            // Test section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "DefaultCalendar", view: nil, handler: nil)
                ]),
            
            // Informations section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "ThirdParty", view: nil, handler: nil)
                ]),
            
            // Logout Section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "Disconnect", view: self.logoutCellGenerate, handler: nil)
                ]),
            
        ]
    }
    
	override func awakeFromNib() {
		self.title = NSLocalizedString("Settings", comment: "")
	}
    
    override func viewDidAppear(_ animated: Bool) {
        self.settingsTableView.reloadData()
    }
	
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].cells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if let data = self.tableData[indexPath.section].cells?[indexPath.row] {
            
            if let cellGenerateFunction = data.view {
                cell = cellGenerateFunction(indexPath, data)
            } else {
                cell.textLabel?.text = NSLocalizedString(data.id, comment: "")
            }
        } else {
            log.error("No cell data for section \(indexPath.section) at row \(indexPath.row)")
        }
        
        return cell
    }
    
    func logoutCellGenerate(indexPath: IndexPath, data: SettingsCellData) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = NSLocalizedString(data.id, comment: "")
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
    
//	
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return _settingsItems.count
//	}
//	
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return _settingsItems[section].count
//	}
//	
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		
//		var cell = UITableViewCell()
//		
//		cell.accessoryType = .none
//		
//		if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "Disconnect") {
//			cell.textLabel?.textAlignment = .center
//			cell.textLabel?.textColor = UIColor(hexString: "#c0392bff")
//			cell.textLabel?.text = NSLocalizedString(_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row], comment: "")
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "DownloadOnData") {
//			cell = tableView.dequeueReusableCell(withIdentifier: "switchCell")!
//			let uiswitch = cell.viewWithTag(1) as! UISwitch
//			let label = cell.viewWithTag(2) as! UILabel
//			uiswitch.onTintColor = UIUtils.backgroundColor
//			uiswitch.isOn = ApplicationManager.sharedInstance.canDownload!
//			uiswitch.addTarget(self, action: #selector(SettingsViewController.switchClicked(_:)), for: .valueChanged)
//			label.text = NSLocalizedString(_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row], comment: "")
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "DefaultCalendar") {
//			
//			if let cal = ApplicationManager.sharedInstance.defaultCalendar {
//				cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
//				let titleLabel = cell.viewWithTag(1) as! UILabel
//				let calendarName = cell.viewWithTag(2) as! UILabel
//				titleLabel.text = NSLocalizedString("DefaultCalendar", comment: "")
//				calendarName.text = cal
//			} else {
//				cell.textLabel?.text = NSLocalizedString("DefaultCalendar", comment: "")
//			}
//			cell.accessoryType = .disclosureIndicator
//			
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "ThirdParty") {
//			cell.accessoryType = .disclosureIndicator
//			cell.textLabel?.text = NSLocalizedString("ThirdParty", comment: "")
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "BugQuestion") {
//			cell.textLabel?.text = NSLocalizedString("BugQuestion", comment: "")
//		}
//		
//		return cell
//	}
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
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		
//		tableView.deselectRow(at: indexPath, animated: true)
//		
//		if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "Disconnect") {
//			disconnectAction()
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "DefaultCalendar") {
//			
//			performSegue(withIdentifier: "SelectCalendarSegue", sender: self)
//			
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "ThirdParty") {
//			showThirdParty()
//		} else if (_settingsItems[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] == "BugQuestion") {
//			sendEmail()
//		} else {
//			//productTest()
//		}
//		
//	}
//	
//	func disconnectAction() {
//		
//		let confirmationMenu = UIAlertController(title: nil, message: NSLocalizedString("WantToDisconnect", comment: ""), preferredStyle: .actionSheet)
//		
//		let disconnect = UIAlertAction(title: NSLocalizedString("Disconnect", comment: ""), style: .destructive, handler: { _ in
//			
//			UserPreferences.deleteData()
//			
//			let storyboard = UIStoryboard(name: "ConnexionStoryboard", bundle: nil)
//			let vc = storyboard.instantiateInitialViewController()
//			self.present(vc!, animated: true, completion: nil)
//		})
//		
//		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
//			print("Cancelled")
//		})
//		
//		confirmationMenu.addAction(disconnect)
//		confirmationMenu.addAction(cancelAction)
//		
//		self.present(confirmationMenu, animated: true, completion: nil)
//	}
//	
//	func switchClicked(_ sender: UISwitch?) {
//		ApplicationManager.sharedInstance.canDownload = sender!.isOn
//		UserPreferences.saveWantToDownloadImage(sender!.isOn)
//	}
//	
//	func sendEmail() {
//		
//		if (MFMailComposeViewController.canSendMail()) {
//			let mailComposerVC = MFMailComposeViewController()
//			mailComposerVC.mailComposeDelegate = self
//			mailComposerVC.setToRecipients(["maxime.junger@epitech.eu"])
//			mailComposerVC.setSubject("IntraEpitech")
//			mailComposerVC.setMessageBody(SystemUtils.getAllMailData(), isHTML: false)
//			self.present(mailComposerVC, animated: true, completion: nil)
//		}
//		
//	}
//	
//	func showThirdParty() {
//        let vc = WebViewController()
//        vc.fileName = "thirdParty"
//        vc.title = NSLocalizedString("ThirdParty", comment: "")
//        self.navigationController?.show(vc, sender: self)
//	}
