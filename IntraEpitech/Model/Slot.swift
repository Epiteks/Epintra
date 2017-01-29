//
//  Appointment.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class Slot {
    
    var date: Date?
    var master: RegisteredStudent?
    var members: [RegisteredStudent]?
    var title: String = ""
    var id: Int!
    
    var open: Bool!
    
    var isPast: Bool!
    
    var isOneshot: Bool!
    
    var canRegister: Bool {
        return self.open && self.master == nil && !self.isPast
    }
    
    var canUnregister: Bool {
        return !self.isOneshot && self.master?.login == ApplicationManager.sharedInstance.user?.login
    }
    
    init(dict: JSON) {
        
        self.date = dict["date"].stringValue.toDate()
        
        if dict["master"] != JSON.null {
            
            self.master = RegisteredStudent(dict: dict["master"])
            self.members = [RegisteredStudent]()
            
            if let membersArray = dict["members"].array {
                
                for student in membersArray {
                    self.members?.append(RegisteredStudent(dict: student))
                }
            }
            
            self.title = dict["title"].stringValue
        }
        self.id = dict["id"].intValue
        
        self.open = dict["status"].string == "open" ? true : false
        
        self.isPast = dict["past"].boolValue
        
        self.isOneshot = dict["bloc_status"].string == "oneshot" ? true : false
    }

    /// Get URL data, needed for all planning API calls
    ///
    /// - Returns: data
    func requestURLData(forEvent event: AppointmentEvent) -> String {
        
        if let groupID = event.groupID {
            return String(format: "?year=%@&module=%@&instance=%@&activity=%@&creneau=%i&team=%i", event.scolaryear!, event.codeModule!, event.codeInstance!, event.codeActi!, self.id, groupID)
        }
        return String(format: "?year=%@&module=%@&instance=%@&activity=%@&creneau=%@&login=%@", event.scolaryear!, event.codeModule!, event.codeInstance!, event.codeActi!, ApplicationManager.sharedInstance.user?.login ?? "")
    }
}
