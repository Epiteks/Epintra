//
//  Spices.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class Spices: NSObject {
	var currentSpices: String
	
	init(dict: JSON) {
		currentSpices = dict["available_spice"].stringValue
	}
}
