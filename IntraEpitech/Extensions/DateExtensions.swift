//
//  DateExtensions.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//
//

import Foundation
import UIKit

public extension Date {
	
	func toAlertString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyy HH:mm"
		let str = dateFormatter.string(from: self)
		return str
	}
	
	func toTitleString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE dd MMMM"
		let str = dateFormatter.string(from: self)
		return str
	}
	
	func toAPIString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let str = dateFormatter.string(from: self)
		return str
	}
	
	func startOfWeek() -> Date? {
		
		guard
			var cal: Calendar = Calendar.current,
			var comp: DateComponents = (cal as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: self) else { return nil }
		cal.firstWeekday = 2// ?? 1
		return cal.date(from: comp)!
	}
	
	func endOfWeek() -> Date? {
		guard
			var cal: Calendar = Calendar.current,
			var comp: DateComponents = (cal as NSCalendar).components([.weekOfYear], from: self) else { return nil }
		cal.firstWeekday = 2
		comp.weekOfYear = 1
		comp.day = -1
		return (cal as NSCalendar).date(byAdding: comp, to: self.startOfWeek()!, options: [])!
	}
	
	func toEventHour() -> String {
		
		var str = String()
		
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		
		str = formatter.string(from: self)
		
		return str
	}
	
	func toProjectEnding() -> String {
		
		var str = String()
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy HH:mm"
		
		str = formatter.string(from: self)
		
		return str
	}
	
	func toActiDate() -> String {
		
		var str = String()
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM"
		
		str = formatter.string(from: self)
		
		return str
	}
	
	func toAppointmentString() -> String {
		
		var str = String()
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		str = formatter.string(from: self)
		
		return str
	}

    init(fromEpirank epirankDateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        self = dateFormatter.date(from: epirankDateString)!
    }
    
}
