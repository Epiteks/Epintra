//
//  User.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
	
	var id: String?
	var login: String?
	var title: String?
	var internalEmail: String?
	var firstname: String?
	var lastname: String?
	var imageUrl: String?
	var semester: Int?
	var promotion: Int?
	var credits: Int?
	var gpa: [GPA]?
	var spices: Spices?
	var log: Netsoul?
	var history: [History]?
	var status: String?
	var city: String?
	var marks: [Mark]?
	var modules: [Module]?
	var phone: String?
    var projects: [Project]?
    var studentyear: Int?
	
	init(dict: JSON) {
		id = dict["id"].stringValue
		login = dict["login"].stringValue
		title = dict["title"].stringValue
		internalEmail = dict["internal_email"].stringValue
		firstname = dict["firstname"].stringValue
		lastname = dict["lastname"].stringValue
		semester = dict["semester"].intValue
		imageUrl = configurationInstance.profilePictureURL + login!.removeDomainEmailPart() + ".bmp"
		promotion = dict["promo"].intValue
		credits = dict["credits"].intValue
		city = dict["location"].stringValue
        studentyear = dict["studentyear"].intValue
		
		let gpas = dict["gpa"].arrayValue
		for gpa in gpas {
			if self.gpa == nil {
				self.gpa = [GPA]()
			}
			
			let gpaObject = GPA(dict: gpa)
			
			self.gpa?.append(gpaObject)
			
		}
		spices = Spices(dict: dict["spice"])
		log = Netsoul(dict: dict["nsstat"])
		
		let infos = dict["userinfo"]
		phone = infos["telephone"]["value"].stringValue
	}
	
	init(little: JSON) {
		login = little["login"].stringValue
		title = little["title"].stringValue
		imageUrl = little["picture"].stringValue
		status = little["status"].stringValue
		city = little["location"].stringValue
	}
	
	init(login: String, promo: Int, city: String) {
		self.login = login
		self.city = city
		promotion = promo
	}
	
	func getLatestGPA() -> GPA {
		
		if gpa?.count == 1 {
			return gpa![0]
		} else if gpa?.count == 2 {
			return gpa![1]
		}
		return GPA()
	}
	
	func fillHistory(_ dict: JSON) {
		
		let array = dict["history"].arrayValue
		
		history = [History]()
		
		for hist in array {
			if history == nil {
				history = [History]()
			}
			history?.append(History(dict: hist))
		}
	}
}
