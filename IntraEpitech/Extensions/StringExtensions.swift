//
//  StringExtensions.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

extension String {
	func toDate() -> Date {
		let strTime: String? = self
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.date(from: strTime!)
		return date!
		
	}
	
	func shortToDate() -> Date? {
		let strTime: String = self
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: strTime) {
            return date
        }
        return nil
	}
	
	func toAppointmentDate() -> Date {
		let strTime: String? = self
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
		let date = dateFormatter.date(from: strTime!)
		return date!
	}
	
}
