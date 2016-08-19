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
	
	var type :String?
	var code :String?
	var seats :Int?
	
	init(dict :JSON)
	{
		type = dict["type"].stringValue
		code = dict["code"].stringValue
		seats = dict["seats"].intValue
	}
	
	func getRoomCleaned() -> String {
		
		let arr = code?.componentsSeparatedByString("/")
		
		if arr != nil && arr!.count == 0 {
			return ""
		}
		
		let res :String = arr![arr!.count - 1]
		
		return res.stringByReplacingOccurrencesOfString("-", withString: " ")	}
}
