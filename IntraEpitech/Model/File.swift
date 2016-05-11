//
//  File.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class File: NSObject {
	
	var _title :String?
	var _url :String?
	
	init(dict :JSON) {
		
		_title = dict["title"].stringValue
		_url = APICalls.getEpitechURL() + dict["fullpath"].stringValue
	}
	
}
