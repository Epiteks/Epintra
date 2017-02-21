//
//  SystemUtils.swift
//  Epintra
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import UIKit

class SystemUtils {
	
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
