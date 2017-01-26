//
//  AppointmentDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class AppointmentDetailsViewController: UIViewController {

    @IBOutlet weak var dataTableView: UITableView!

    var appointment: AppointmentEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.appointment.eventName
        
        self.dataTableView.rowHeight = UITableViewAutomaticDimension
        self.dataTableView.estimatedRowHeight = 50
        
        self.dataTableView.register(UINib(nibName: "SlotTakenTableViewCell", bundle: nil), forCellReuseIdentifier: "slotTakenTableViewCell")
        self.dataTableView.register(UINib(nibName: "SlotRegisterTableViewCell", bundle: nil), forCellReuseIdentifier: "slotRegisterTableViewCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            if data.master == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "slotRegisterTableViewCell") as! SlotRegisterTableViewCell
                return cell
            } else if data.master != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "slotTakenTableViewCell") as! SlotTakenTableViewCell
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
    }
    
}
