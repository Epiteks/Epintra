//
//  StudentInfo.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 21/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class StudentInfo: NSObject {
	
	var _login :String?
	var _city :String?
	var _gpa :Float?
	var _promo :String?
	
	var _position :Int?
	
	init(dict :JSON, promo :String) {
		
		_login = dict["login"].stringValue
		_city = dict["ville"].stringValue
		
		let cit = dict["ville"].stringValue
		if (cit.containsString("/")) {
			_city = cit.componentsSeparatedByString("/")[1]
		}
		
		_gpa = dict["gpa"].floatValue
		_promo = promo
	}
	
	override init() {
		super.init()
	}
}
