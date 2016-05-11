//
//  GPA.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class GPA: NSObject {
	internal var _value :String
	internal var _cycle :String
	
	init(dict :JSON) {
		_value = dict["gpa"].stringValue
		_cycle = dict["cycle"].stringValue
	}
	
	override init()
	{
		_value = "0"
		_cycle = NSLocalizedString("unknown", comment: "")
	}
}
