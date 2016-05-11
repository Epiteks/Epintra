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

public extension NSDate {
	
	func toAlertString() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyy HH:mm"
		let str = dateFormatter.stringFromDate(self)
		return str
	}
	
	func toTitleString() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE dd MMMM"
		let str = dateFormatter.stringFromDate(self)
		return str
	}
	
	func toAPIString() -> String
	{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let str = dateFormatter.stringFromDate(self)
		return str
	}
	
	func startOfWeek() -> NSDate? {
		
		guard
			let cal: NSCalendar = NSCalendar.currentCalendar(),
			let comp: NSDateComponents = cal.components([.YearForWeekOfYear, .WeekOfYear], fromDate: self) else { return nil }
		cal.firstWeekday = 2// ?? 1
		return cal.dateFromComponents(comp)!
	}
	
	func endOfWeek() -> NSDate? {
		guard
			let cal: NSCalendar = NSCalendar.currentCalendar(),
			let comp: NSDateComponents = cal.components([.WeekOfYear], fromDate: self) else { return nil }
		cal.firstWeekday = 2
		comp.weekOfYear = 1
		comp.day = -1
		return cal.dateByAddingComponents(comp, toDate: self.startOfWeek()!, options: [])!
	}
	
	func toEventHour() -> String {
		
		var str = String()
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "HH:mm"
		
		str = formatter.stringFromDate(self)
		
		return str
	}
	
	func toProjectEnding() -> String {
		
		var str = String()
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "dd/MM/yyyy HH:mm"
		
		str = formatter.stringFromDate(self)
		
		return str
	}
	
	func toActiDate() -> String {
		
		var str = String()
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "dd/MM"
		
		str = formatter.stringFromDate(self)
		
		return str
	}
	
	func toAppointmentString() -> String {
		
		var str = String()
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		str = formatter.stringFromDate(self)
		
		return str
	}
}

