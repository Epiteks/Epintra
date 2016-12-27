//
//  SystemUtils.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import UIKit

class SystemUtils: NSObject {
	
	func getDateUnderstandable(_ day: Int, month: Int) -> (s_day: String?, s_month: String?) {
		
		var s_day = String()
		var s_month = String()
		
		let days:  [String] = [
			NSLocalizedString("Sunday", comment: ""),
			NSLocalizedString("Monday", comment: ""),
			NSLocalizedString("Tuesday", comment: ""),
			NSLocalizedString("Wednesday", comment: ""),
			NSLocalizedString("Thursday", comment: ""),
			NSLocalizedString("Friday", comment: ""),
			NSLocalizedString("Saturday", comment: "")
		]
		
		let monthes:  [String] = [
			NSLocalizedString("January", comment: ""),
			NSLocalizedString("February", comment: ""),
			NSLocalizedString("March", comment: ""),
			NSLocalizedString("April", comment: ""),
			NSLocalizedString("May", comment: ""),
			NSLocalizedString("June", comment: ""),
			NSLocalizedString("July", comment: ""),
			NSLocalizedString("August", comment: ""),
			NSLocalizedString("September", comment: ""),
			NSLocalizedString("October", comment: ""),
			NSLocalizedString("November", comment: ""),
			NSLocalizedString("December", comment: "")
		]
		
		s_day = days[day - 1]
		s_month = monthes[month - 1]
		
		return (s_day, s_month)
	}
	
	class func getVersion() -> String {
		let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
		return nsObject as! String
	}
	
	class func getAllMailData() -> String {
		let currentDevice = UIDevice.current
		var str = "Version:  " + SystemUtils.getVersion()
		str += "\n" + "Model:  " + currentDevice.modelName
		str += "\n" + "iOS:  " + currentDevice.systemVersion
		return str
	}
}
