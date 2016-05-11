
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
	
	
	
	var _id 			:String?
	var _login 			:String?
	var _title			:String?
	var _internalEmail	:String?
	var _firstname		:String?
	var _lastname		:String?
	var _imageUrl 		:String?
	var _semester		:Int?
	var _promotion		:Int?
	var _credits		:Int?
	var _gpa			:[GPA]?
	var _spices			:Spices?
	var _log			:Netsoul?
	var _history		:[History]?
	var _status 		:String?
	var _city			:String?
	var _marks			:[Mark]?
	var _modules		:[Module]?
	var _phone			:String?
	
	init(dict :JSON)
	{
		_id = dict["id"].stringValue
		_login = dict["login"].stringValue
		_title = dict["title"].stringValue
		_internalEmail = dict["internal_email"].stringValue
		_firstname = dict["firstname"].stringValue
		_lastname = dict["lastname"].stringValue
		_semester = dict["semester"].intValue
		_imageUrl = APICalls.getProfilePictureURL() + _login! + ".bmp"
		_promotion = dict["promo"].intValue
		_credits = dict["credits"].intValue
		_city = dict["location"].stringValue
		
		let gpas = dict["gpa"].arrayValue
		for gpa in gpas {
			if (_gpa == nil) {
				_gpa = [GPA]()
			}
			_gpa?.append(GPA(dict: gpa))
		}
		_spices = Spices(dict: dict["spice"])
		_log = Netsoul(dict: dict["nsstat"])
		
		let infos = dict["userinfo"]
		_phone = infos["telephone"]["value"].stringValue
	}
	
	init(little :JSON) {
		_login = little["login"].stringValue
		_title = little["title"].stringValue
		_imageUrl = little["picture"].stringValue
		_status = little["status"].stringValue
		_city = little["location"].stringValue
	}
	
	init(login :String, promo :Int, city :String) {
		_login = login
		_city = city
		_promotion = promo
	}
	
	func getLatestGPA() -> GPA {
		
		if (_gpa?.count == 1)
		{
			return _gpa![0]
		}
		else if (_gpa?.count == 2)
		{
			return _gpa![1]
		}
		return GPA()
	}
	
	func fillHistory(dict :JSON) {
		
		let array = dict["history"].arrayValue
		
		_history = [History]()
		
		for hist in array {
			if (_history == nil) {
				_history = [History]()
			}
			_history?.append(History(dict: hist))
		}
	}
}