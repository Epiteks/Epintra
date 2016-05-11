//
//  ProjectGroup.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectGroup: NSObject {
	
	var _title :String?
	var _code :String?
	var _finalNote :String?
	var _master :User?
	var _members :[User]?
	
	init(dict :JSON)
	{
		super.init()
		_title = dict["title"].stringValue
		_code = dict["code"].stringValue
		_finalNote = dict["final_note"].stringValue
		_master = User(dict: (dict["master"]))
		fillMembers(dict)
	}
	
	func fillMembers(dict :JSON) {
		_members = [User]()
		
		let arr = dict["members"].arrayValue
		
		for tmp in arr {
			_members?.append(User(little: tmp))
		}
	}
}
