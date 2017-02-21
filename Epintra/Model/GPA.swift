//
//  GPA.swift
//  Epintra
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class GPA {
    
	internal var value: Float
	internal var cycle: String
	
	init(dict: JSON) {
		value = dict["gpa"].floatValue
		cycle = dict["cycle"].stringValue
	}
	
    init() {
		value = 0
		cycle = NSLocalizedString("unknown", comment: "")
	}
}
