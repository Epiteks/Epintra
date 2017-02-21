//
//  String+NSDate.swift
//  Epintra
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

public extension String {
	
	func toSortedDate() -> Date {
		
		let formater = DateFormatter()
		formater.dateFormat = "yyyy-MM-dd"
		let res = formater.date(from: self)
		
		return res!
		
	}
	
}
