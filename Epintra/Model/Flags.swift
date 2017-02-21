//
//  Flags.swift
//  Epintra
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import SwiftyJSON

class Flags {
	
	var name: String?
	var label: String?
	var modules: [Module]
	
	init(name: String, dict: JSON) {
		self.name = name
		self.label = dict["label"].stringValue
		
		let arr = dict["modules"].arrayValue
		self.modules = [Module]()
		for tmp in arr {
			let tmp2 = Module(dict: tmp)
			self.modules.append(tmp2)
		}
	}
}
