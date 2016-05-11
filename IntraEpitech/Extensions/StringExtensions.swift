//
//  StringExtensions.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

extension String {
	func toDate() -> NSDate {
		let strTime: String? = self
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.dateFromString(strTime!)
		return date!
		
	}
	
	func shortToDate() -> NSDate {
		let strTime: String? = self
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let date = dateFormatter.dateFromString(strTime!)
		return date!
		
	}
	
	func toAppointmentDate() -> NSDate {
		let strTime: String? = self
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
		let date = dateFormatter.dateFromString(strTime!)
		return date!
	}
	
}
