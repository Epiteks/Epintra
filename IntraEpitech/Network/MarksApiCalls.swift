//
//  MarksApiCalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class MarksApiCalls: APICalls {
	
	class func getMarks(_ onCompletion: @escaping (Bool, [Mark]?, String) ->Void) {
		
		let url = super.getApiUrl() + "marks"
		
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
						var resp = [Mark]()
						for tmp in arr {
							resp.insert(Mark(dict: tmp), at: 0)
							//							resp.append(Mark(dict: tmp))
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					//print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectMarks(_ mark: Mark, onCompletion: @escaping (Bool, [Mark]?, String) ->Void) {
		
		let url = super.getApiUrl() + "project/marks"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": mark.scolaryear!,
			"codemodule": mark.codemodule!,
			"codeinstance": mark.codeinstance!,
			"codeacti": mark.codeacti!])
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
						var resp = [Mark]()
						for tmp in arr {
							resp.append(Mark(little: tmp))
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					//print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectMarksForProject(_ proj: Project, onCompletion: @escaping (Bool, [Mark]?, String) ->Void) {
		
		let url = super.getApiUrl() + "project/marks"
		
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
						let arr = responseCall.arrayValue
						var resp = [Mark]()
						for tmp in arr {
							resp.append(Mark(little: tmp))
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					//print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getMarksFor(user login: String, onCompletion: @escaping (Bool, [Mark]?, String) ->Void) {
		
		let url = super.getApiUrl() + "marks"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "login": login])
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
						var resp = [Mark]()
						for tmp in arr {
							resp.insert(Mark(dict: tmp), at: 0)
							//							resp.append(Mark(dict: tmp))
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					//print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
}
