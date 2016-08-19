//
//  Netsoul.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class Netsoul: NSObject {
	
	var	timeActive :Int
	var timeNormal :Int
	
	init(dict :JSON) {
		timeActive = dict["active"].intValue
		timeNormal = dict["nslog_norm"].intValue
	}
	
	func getColor() -> UIColor {
		
		let current = Int(timeActive)
		let normal = Int(timeNormal)
		
		if (current >= normal) {
			return UIUtils.netsoulGreenColor()
		}
		return UIUtils.netsoulRedColor()
	}
}
