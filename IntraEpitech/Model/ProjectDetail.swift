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
	
	var projectDescription :String?
	var userProjectStatus :String?
	var note :String?
	var userProjectCode :String?
	var userProjectTitle :String?
	var registeredGroups :[ProjectGroup]?
	var projectStatus :String?
	var files :[File]?
	
	override init(dict :JSON) {
		super.init(dict: dict)
		
		projectDescription = dict["description"].stringValue
		userProjectStatus = dict["user_project_status"].stringValue
		note = dict["note"].stringValue
		userProjectCode = dict["user_project_code"].stringValue
		userProjectTitle = dict["user_project_title"].stringValue
		beginActi = dict["begin"].stringValue
		endActi = dict["end"].stringValue
		actiTitle = dict["title"].stringValue
		registered =  dict["instance_registered"].boolValue
		projectStatus = dict["user_project_status"].stringValue
		fillProjectGroups(dict["registered"])
	}
	
	func fillProjectGroups(dict :JSON)
	{
		registeredGroups = [ProjectGroup]()
		let arr = dict.arrayValue
		print(arr.count)
		for tmp in arr {
			registeredGroups?.append(ProjectGroup(dict: tmp))
		}
	}
	
	func findGroup(code :String) -> ProjectGroup?
	{
		var res : ProjectGroup?
		for tmp in registeredGroups!
		{
			if (tmp.code == code) {
				res = tmp
				break
			}
		}
		
		return res
	}
	
	func isRegistered() -> Bool {
		if (projectStatus == "project_confirmed") {
			return true
		}
		return false
	}
}
