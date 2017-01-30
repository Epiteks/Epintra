//
//  AppointmentDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class AppointmentDetailsViewController: LoadingDataViewController {

    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var showInformationBarButton: UIBarButtonItem!

    var appointment: AppointmentEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("appointment", comment: "")// self.appointment.eventName
        self.showInformationBarButton.title = NSLocalizedString("info", comment: "")
        
        self.dataTableView.rowHeight = UITableViewAutomaticDimension
        self.dataTableView.estimatedRowHeight = 50
        
        self.dataTableView.register(UINib(nibName: "SlotTakenTableViewCell", bundle: nil), forCellReuseIdentifier: "slotTakenTableViewCell")
        self.dataTableView.register(UINib(nibName: "SlotRegisterTableViewCell", bundle: nil), forCellReuseIdentifier: "slotRegisterTableViewCell")
        self.dataTableView.register(UINib(nibName: "SlotRegisteredGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "slotRegisteredGroupTableViewCell")
        
        if self.appointment.eventName == nil && self.appointment.blockTitle == nil {
            self.showInformationBarButton.title = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func infoBarButtonItemTouched(_ sender: Any) {
        if self.appointment.eventName != nil || self.appointment.blockTitle != nil {
            self.showAlert(withTitle: self.appointment.eventName ?? "", andMessage: self.appointment.blockTitle ?? "")
        }
    }
}

extension AppointmentDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.appointment.slots?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let date = appointment.slots?[section].date {
            return date.toSlotTitleString()
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointment.slots?[section].slots.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let data = self.appointment.slots?[indexPath.section].slots[indexPath.row] {
            
            if data.master == nil { // Slot free
                let cell = tableView.dequeueReusableCell(withIdentifier: "slotRegisterTableViewCell") as! SlotRegisterTableViewCell
                cell.setView(slot: data, appointment: self.appointment)
                return cell
            } else if data.master != nil && data.members == nil { // Slot taken by one person only
                let cell = tableView.dequeueReusableCell(withIdentifier: "slotTakenTableViewCell") as! SlotTakenTableViewCell
                cell.setView(slot: data)
                return cell
            } else if data.master != nil && data.members != nil { // Slot taken by a group
                let cell = tableView.dequeueReusableCell(withIdentifier: "slotRegisteredGroupTableViewCell") as! SlotRegisteredGroupTableViewCell
                cell.setView(slot: data)
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
}

extension AppointmentDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let data = self.appointment.slots?[indexPath.section].slots[indexPath.row] {
            
            if data.canRegister && self.appointment.canRegister {
               self.subscribe(toSlot: data, forIndexPath: indexPath)
            } else if data.canUnregister {
              self.unsubscribe(fromSlot: data, forIndexPath: indexPath)
            }
        }
    }
    
   private func subscribe(toSlot data: Slot, forIndexPath indexPath: IndexPath) {
     
        planningRequests.register(toSlot: data, forEvent: self.appointment, completion: { response in
            switch response {
            case .success(_):
                self.dataTableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let err):
                self.showAlert(withTitle: "error", andMessage: err.message)
            }
            
        })
        
    }
    
    private func unsubscribe(fromSlot data: Slot, forIndexPath indexPath: IndexPath) {
        
        planningRequests.unregister(fromSlot: data, forEvent: self.appointment, completion: { response in
            switch response {
            case .success(_):
                self.dataTableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let err):
                self.showAlert(withTitle: "error", andMessage: err.message)
            }
            
        })
        
    }
    
}
