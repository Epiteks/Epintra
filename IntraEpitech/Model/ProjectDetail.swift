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
	
//	var explanations: String?
//	var userProjectStatus: String?
//	var note: String?
//	var userProjectCode: String?
//	var userProjectTitle: String?
//	var registeredGroups: [ProjectGroup]?
//	var projectStatus: String?
//	var files: [File]?
//	
//	override init(dict: JSON) {
//		super.init(dict: dict)
//		
//		explanations = dict["description"].stringValue
//		userProjectStatus = dict["user_project_status"].stringValue
//		note = dict["note"].stringValue
//		userProjectCode = dict["user_project_code"].stringValue
//		userProjectTitle = dict["user_project_title"].stringValue
//		begin = dict["begin"].stringValue
//		end = dict["end"].stringValue
//		actiTitle = dict["title"].stringValue
//		registered =  dict["instance_registered"].boolValue
//		projectStatus = dict["user_project_status"].stringValue
//		fillProjectGroups(dict["registered"])
//	}
//	
//	func fillProjectGroups(_ dict: JSON) {
//		registeredGroups = [ProjectGroup]()
//		let arr = dict.arrayValue
//		print(arr.count)
//		for tmp in arr {
//			registeredGroups?.append(ProjectGroup(dict: tmp))
//		}
//	}
//	
//	func findGroup(_ code: String) -> ProjectGroup? {
//		var res:  ProjectGroup?
//		for tmp in registeredGroups! {
//			if (tmp.code == code) {
//				res = tmp
//				break
//			}
//		}
//		
//		return res
//	}
//	
//	func isRegistered() -> Bool {
//		if (projectStatus == "project_confirmed") {
//			return true
//		}
//		return false
//	}
}
