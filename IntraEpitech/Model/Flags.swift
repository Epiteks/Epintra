//
//  Flags.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class Flags: NSObject {
	
	var _name :String?
	var _label :String?
	var _modules :[Module]
	
	init(name :String, dict :JSON)
	{
		_name = name
		_label = dict["label"].stringValue
		
		let arr = dict["modules"].arrayValue
		_modules = [Module]()
		for tmp in arr {
			let tmp2 = Module(dict: tmp)
			_modules.append(tmp2)
		}
	}
}
