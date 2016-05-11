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
	
	var _login :String!
	var _grade :String!
	var _status :String!
	var _imageURL :String!
	
	init(dict :JSON) {
		
		_login = dict["login"].stringValue
		_grade = dict["grade"].stringValue
		_status = dict["present"].stringValue
		_imageURL = dict["picture"].stringValue

		if (dict["picture"].stringValue.characters.count > 0 && dict["picture"].stringValue.characters.count <= 12) {
			_imageURL = APICalls.getProfilePictureURL() + _login + ".bmp"
		}
	}
	
}
