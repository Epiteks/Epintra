//
//  RegisteredStudent.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 03/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class RegisteredStudent: NSObject {
	
	var login: String!
	var grade: String!
	var status: String!
	var imageURL: String!
	
	init(dict: JSON) {
		
		login = dict["login"].stringValue
		grade = dict["grade"].stringValue
		status = dict["present"].stringValue
		imageURL = dict["picture"].stringValue

		if (dict["picture"].stringValue.characters.count > 0 && dict["picture"].stringValue.characters.count <= 12) {
			imageURL = APICalls.getProfilePictureURL() + login + ".bmp"
		}
	}
	
}
