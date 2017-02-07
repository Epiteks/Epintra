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
import EventKit

class SettingsViewController: LoadingDataViewController {

    struct SettingsCellData {
        var id: String!
        var view: ((IndexPath, SettingsCellData) -> (UITableViewCell))?
        var handler: (() -> Void)?
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
            // Calendar section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "DefaultCalendar", view: self.calendarCellGenerate, handler: self.selectCalendarViewController)
                ]),
            
            // Informations section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "ThirdParty", view: nil, handler: self.thirdPartyViewController),
                SettingsCellData(id: "BugQuestion", view: nil, handler: self.sendEmail)
                ]),
            
            // Logout Section
            SettingsSectionData(name: nil, cells: [
                SettingsCellData(id: "Disconnect", view: self.logoutCellGenerate, handler: self.disconnect)
                ])
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
    
    func calendarCellGenerate(indexPath: IndexPath, data: SettingsCellData) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "calendarCell")

        cell.textLabel?.text = NSLocalizedString(data.id, comment: "")
        
        if let defaultCalendarIdentifier = ApplicationManager.sharedInstance.defaultCalendarIdentifier, let calendar = CalendarManager.getCalendar(forIdentifier: defaultCalendarIdentifier) {
            cell.detailTextLabel?.text = calendar.title
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let data = self.tableData[indexPath.section].cells?[indexPath.row] {
            data.handler?()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func disconnect() {
        
        let confirmationMenu = UIAlertController(title: nil, message: NSLocalizedString("WantToDisconnect", comment: ""), preferredStyle: .actionSheet)
        
        let disconnect = UIAlertAction(title: NSLocalizedString("Disconnect", comment: ""), style: .destructive, handler: { _ in
            
            KeychainUtil.deleteCredentials()
            
            let storyboard = UIStoryboard(name: "ConnexionStoryboard", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            self.present(vc!, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        confirmationMenu.addAction(disconnect)
        confirmationMenu.addAction(cancelAction)
        
        self.present(confirmationMenu, animated: true, completion: nil)
    }

    func thirdPartyViewController() {
        let vc = WebViewController()
        vc.fileName = "thirdParty"
        vc.title = NSLocalizedString("ThirdParty", comment: "")
        self.navigationController?.show(vc, sender: self)
    }
    
    func selectCalendarViewController() {
        self.performSegue(withIdentifier: "SelectCalendarSegue", sender: self)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func sendEmail() {
        if (MFMailComposeViewController.canSendMail()) {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["maxime.junger@epitech.eu"])
            mailComposerVC.setSubject("IntraEpitech")
            mailComposerVC.setMessageBody(SystemUtils.getAllMailData(), isHTML: false)
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            log.error("Cannot send email")
            self.showAlert(withTitle: NSLocalizedString("cannotSendEmail", comment: ""))
        }
    }
}
