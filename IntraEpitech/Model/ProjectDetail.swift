//
//  ProjectDetail.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectDetail: Project {
	
	var _description :String?
	var _userProjectStatus :String?
	var _note :String?
	var _userProjectCode :String?
	var _userProjectTitle :String?
	var _registeredGroups :[ProjectGroup]?
	var _projectStatus :String?
	var _files :[File]?
	
	override init(dict :JSON) {
		super.init(dict: dict)
		
		_description = dict["description"].stringValue
		_userProjectStatus = dict["user_project_status"].stringValue
		_note = dict["note"].stringValue
		_userProjectCode = dict["user_project_code"].stringValue
		_userProjectTitle = dict["user_project_title"].stringValue
		_beginActi = dict["begin"].stringValue
		_endActi = dict["end"].stringValue
		_actiTitle = dict["title"].stringValue
		_registered =  dict["instance_registered"].boolValue
		_projectStatus = dict["user_project_status"].stringValue
		fillProjectGroups(dict["registered"])
	}
	
	func fillProjectGroups(dict :JSON)
	{
		_registeredGroups = [ProjectGroup]()
		let arr = dict.arrayValue
		print(arr.count)
		for tmp in arr {
			_registeredGroups?.append(ProjectGroup(dict: tmp))
		}
	}
	
	func findGroup(code :String) -> ProjectGroup?
	{
		var res : ProjectGroup?
		for tmp in _registeredGroups!
		{
			if (tmp._code == code) {
				res = tmp
				break
			}
		}
		
		return res
	}
	
	func isRegistered() -> Bool {
		if (_projectStatus == "project_confirmed") {
			return true
		}
		return false
	}
}
