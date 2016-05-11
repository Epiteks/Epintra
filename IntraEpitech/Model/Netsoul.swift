//
//  Netsoul.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class Netsoul: NSObject {
	
	var	_timeActive :Int
	var _timeNormal :Int
	
	init(dict :JSON)
	{
		_timeActive = dict["active"].intValue
		_timeNormal = dict["nslog_norm"].intValue
	}
	
	func getColor() -> UIColor {
		
		let current = Int(_timeActive)
		let normal = Int(_timeNormal)
		
		if (current >= normal)
		{
			return UIUtils.netsoulGreenColor()
		}
		return UIUtils.netsoulRedColor()
	}
}
