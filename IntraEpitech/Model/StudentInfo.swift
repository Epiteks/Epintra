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
	
	var login :String?
	var city :String?
	var gpa :Float?
	var promo :String?
	
	var position :Int?
	
	init(dict :JSON, promo :String) {
		
		login = dict["login"].stringValue
		city = dict["ville"].stringValue
		
		let cit = dict["ville"].stringValue
		if (cit.containsString("/")) {
			city = cit.componentsSeparatedByString("/")[1]
		}
		
		gpa = dict["gpa"].floatValue
		self.promo = promo
	}
	
	override init() {
		super.init()
	}
}
