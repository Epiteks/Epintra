//
//  String+NSDate.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

public extension String {
	
	func toSortedDate() -> NSDate {
		
		let formater = NSDateFormatter()
		formater.dateFormat = "yyyy-MM-dd"
		let res = formater.dateFromString(self)
		
		return res!
		
	}
	
}
