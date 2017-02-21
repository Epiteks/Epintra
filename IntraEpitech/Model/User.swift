//
//  User.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift

class User {
	
	/// User login
	var login: String?
    
	/// User title (first name + last name)
	var title: String?

	/// Profile image URL
	var imageUrl: String?
    
	/// Current semester
	var semester: Int?
    
	/// Current promotion
	var promotion: Int?
    
	/// Credits number
	var credits: Int?
    
	/// Available GPA (bachelor/master)
	var gpa: [GPA]?
    
	/// Available spices
	var spices: Spices?
    
	/// Current log
	var log: Netsoul?
    
    /// Notifications history
    var history = Variable<[History]>([])

	/// 🚧 Member status : Only used in Little user
	var status: String?
    
	/// Current city
	var city: String?
    
	/// All marks
	var marks: [Mark]?
    
	/// All modules
	var modules: [Module]?
    
    /// All projects from student
    var projects: [Project]?
    
    /// Current year
    var studentyear: Int?
	
    /// Creates user with all available data from Intranet.
    ///
    /// - Parameter dict: JSON response
    init(dict: JSON) {
        self.setData(fromJSON: dict)
    }
    
    /// Creates user with login
    ///
    /// - Parameter login: user email
    init(login: String) {
        self.login = login
    }
	
	init(little: JSON) {
		self.login = little["login"].stringValue
		self.title = little["title"].stringValue
		self.imageUrl = little["picture"].stringValue
		self.status = little["status"].stringValue
		self.city = little["location"].stringValue
	}
	
	init(login: String, promo: Int, city: String) {
		self.login = login
		self.city = city
		self.promotion = promo
	}
	
    func setData(fromJSON dict: JSON) {
        self.login = dict["login"].stringValue
        self.title = dict["title"].stringValue
        
        self.semester = dict["semester"].intValue
        self.imageUrl = Configuration.profilePictureURL + login!.removeDomainEmailPart() + ".bmp"
        self.promotion = dict["promo"].intValue
        self.credits = dict["credits"].intValue
        self.city = dict["location"].stringValue
        self.studentyear = dict["studentyear"].intValue
        
        let gpas = dict["gpa"].arrayValue
        for gpa in gpas {
            if self.gpa == nil {
                self.gpa = [GPA]()
            }
            
            let gpaObject = GPA(dict: gpa)
            
            self.gpa?.append(gpaObject)
            
        }
        self.spices = Spices(dict: dict["spice"])
        self.log = Netsoul(dict: dict["nsstat"])
    }
    
	func getLatestGPA() -> GPA {
		
        if let count = self.gpa?.count, count > 0 {
            return self.gpa![count - 1]
        }
        
		return GPA()
	}
	
    
	/// Fill notifications history data
	///
	/// - Parameter dict: JSON data
	func fillHistory(_ dict: JSON) {
		
        var tmpArray = [History]()
        
        for hist in dict["history"].arrayValue {
			tmpArray.append(History(dict: hist))
		}
        
        self.history.value.append(contentsOf: tmpArray)
	}
    
    /// Check if the user profile contains enough information to be displayed on profile
    func enoughDataForProfile() -> Bool {
        return self.spices != nil && self.log != nil && self.gpa != nil && self.credits != nil
    }
}
