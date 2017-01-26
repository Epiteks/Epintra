//
//  RegisteredStudent.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 03/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class RegisteredStudent {
	
	/// User login aka email
	var login: String!
    
    /// User title (Firstname Lastname)
    var title: String!
    
    /// User profile image url
    var imageURL: String!
	
    /// Student grade (user for modules registered view controller)
    var grade: String?
    
    init(dict: JSON) {
		self.login = dict["login"].stringValue
        self.title = dict["title"].stringValue
		self.imageURL = dict["picture"].stringValue
        self.grade = dict["grade"].stringValue
	}
	
}
