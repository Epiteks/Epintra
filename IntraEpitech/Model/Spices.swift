//
//  Spices.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

struct Spices {

	var currentSpices: Int
	
	init(dict: JSON) {
		currentSpices = dict["available_spice"].intValue
	}
}
