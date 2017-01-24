//
//  Project.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Project: BasicInformation {
	
	var typeActiCode :String?
	var projectName :String?
	var actiTitle :String?
	var titleModule :String?
	var begin :String?
	
	var codeActi :String?
	var end :String?
	var registered :Bool?
	var mark :String?
    var marks: [Mark]?
    
    var explanations: String?
    var userProjectStatus: String?
    var note: String?
    var userProjectCode: String?
    var userProjectTitle: String?
    var registeredGroups: [ProjectGroup]?
    var projectStatus: String?
    var files: [File]?
	
	override init(dict :JSON) {
        
        super.init(dict: dict)
        
		self.typeActiCode = dict["type_acti_code"].stringValue
		self.projectName = dict["project_title"].stringValue
		
		self.actiTitle = dict["acti_title"].stringValue
		self.titleModule = dict["title_module"].stringValue
		self.begin = dict["begin_acti"].stringValue
		self.codeActi = dict["codeacti"].stringValue
		self.end = dict["end_acti"].stringValue
		self.registered = dict["registered"].boolValue
	}
	
	init(detail :JSON) {
        super.init(dict: detail)
		self.codeActi = detail["codeacti"].stringValue
		self.typeActiCode = detail["type_code"].stringValue
		self.actiTitle = detail["title"].stringValue
		self.titleModule = detail["module_title"].stringValue
		self.begin = detail["begin"].stringValue
		self.end = detail["end"].stringValue
		self.mark = detail["note"].stringValue
        self.projectName = detail["project_title"].stringValue
	}
    
    func addModuleData(module: Module) {
        self.codeInstance = module.codeInstance
        self.scolaryear = module.scolaryear
        self.codeModule = module.codeModule
    }
    
    func fillProjectGroups(_ dict: JSON) {
        registeredGroups = [ProjectGroup]()
        let arr = dict.arrayValue
        print(arr.count)
        for tmp in arr {
            registeredGroups?.append(ProjectGroup(dict: tmp))
        }
    }
    
    func findGroup(_ code: String) -> ProjectGroup? {
        var res:  ProjectGroup?
        for tmp in registeredGroups! {
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

    func setDetails(dict: JSON) {
        explanations = dict["description"].stringValue
        userProjectStatus = dict["user_project_status"].stringValue
        note = dict["note"].stringValue
        userProjectCode = dict["user_project_code"].stringValue
        userProjectTitle = dict["user_project_title"].stringValue
        begin = dict["begin"].stringValue
        end = dict["end"].stringValue
        actiTitle = dict["title"].stringValue
        registered =  dict["instance_registered"].boolValue
        projectStatus = dict["user_project_status"].stringValue
        fillProjectGroups(dict["registered"])
    }
}
