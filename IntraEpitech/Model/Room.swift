//
//  Room.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Room: NSObject {
	
	var _type :String?
	var _code :String?
	var _seats :Int?
	
	init(dict :JSON)
	{
		_type = dict["type"].stringValue
		_code = dict["code"].stringValue
		_seats = dict["seats"].intValue
	}
	
	func getRoomCleaned() -> String {
		
		let arr = _code?.componentsSeparatedByString("/")
		
		if (arr != nil && arr!.count == 0)
		{
			return ""
		}
		
		let res :String = arr![arr!.count - 1]
		
		return res.stringByReplacingOccurrencesOfString("-", withString: " ")	}
}
