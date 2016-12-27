//
//  ProjectsApiCall.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProjectsApiCall: APICalls {
	
	class func getCurrentProjects(_ onCompletion: @escaping (Bool, [Project]?, String) ->Void) {
		
		let url = super.getApiUrl() + "projects"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						let arr = responseCall.arrayValue
						var resp = [Project]()
						for tmp in arr {
							
							if (tmp["type_acti_code"].stringValue == "proj") {
								resp.append(Project(dict: tmp))
							}
						}
						onCompletion(true, resp, "Ok")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectDetails(_ proj: Project, onCompletion: @escaping (Bool, ProjectDetail?, String) ->Void) {
		
		let url = super.getApiUrl() + "project"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": proj.scolaryear!,
			"codemodule": proj.codeModule!,
			"codeinstance": proj.codeInstance!,
			"codeacti": proj.codeActi!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						let proj = ProjectDetail(dict: responseCall)
						onCompletion(true, proj, "Ok")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectFiles(_ proj: Project, onCompletion: @escaping (Bool, [File]?, String) ->Void) {
		
		let url = super.getApiUrl() + "project/files"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": proj.scolaryear!,
			"codemodule": proj.codeModule!,
			"codeinstance": proj.codeInstance!,
			"codeacti": proj.codeActi!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						var resp = [File]()
						let arr = responseCall.arrayValue
					 
						for tmp in arr {
							resp.append(File(dict: tmp))
						}
						
						onCompletion(true, resp, "Ok")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
}
