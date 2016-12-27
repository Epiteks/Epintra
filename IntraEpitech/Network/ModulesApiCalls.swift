//
//  ModulesApiCalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ModulesApiCalls: APICalls {
	
	class func getRegisteredModules(_ onCompletion: @escaping (Bool, [Module]?, String) ->Void) {
		
		let url = super.getApiUrl() + "modules"
		
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
						var resp = [Module]()
						for tmp in arr {
							resp.insert(Module(dict: tmp), at: 0)
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getRegisteredModulesFor(user login: String, onCompletion: @escaping (Bool, [Module]?, String) ->Void) {
		
		let url = super.getApiUrl() + "modules"
		
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
						var resp = [Module]()
						for tmp in arr {
							resp.insert(Module(dict: tmp), at: 0)
						}
						onCompletion(true, resp, "Ok")
					}
					
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getModule(_ mod: Module, onCompletion: @escaping (Bool, Module?, String) ->Void) {
		
		let url = super.getApiUrl() + "module"
		
//		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
//			"scolaryear": mod.scolaryear!,
//			"codemodule": mod.codemodule!,
//			"codeinstance": mod.codeinstance!])
//			.responseJSON { response in
//				if (response.result.isSuccess) {
//					let responseCall = JSON(response.result.value!)
//					let errorDict = responseCall["error"].dictionaryValue
//					let errorMessage: String?
//					if (errorDict.count > 0) {
//						errorMessage = (errorDict["message"]?.stringValue)
//						onCompletion(false, nil, errorMessage!)
//					} else {
////						let resp = Module(detail: responseCall)
////						onCompletion(true, resp, "Ok")
//					}
//					
//				} else {
//					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
//				}
//		}
	}
	
	class func getRegistered(_ mod: Module, onCompletion: @escaping (Bool, [RegisteredStudent]?, String) ->Void) {
		
		let url = super.getApiUrl() + "module/registered"
		
//		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
//			"scolaryear": mod.scolaryear!,
//			"codemodule": mod.codemodule!,
//			"codeinstance": mod.codeinstance!])
//			.responseJSON { response in
//				if (response.result.isSuccess) {
//					let responseCall = JSON(response.result.value!)
//					let errorDict = responseCall["error"].dictionaryValue
//					let errorMessage: String?
//					if (errorDict.count > 0) {
//						errorMessage = (errorDict["message"]?.stringValue)
//						onCompletion(false, nil, errorMessage!)
//					} else {
//						let arr = responseCall.arrayValue
//						
//						var resp = [RegisteredStudent]()
//						for tmp in arr {
//							resp.append(RegisteredStudent(dict: tmp))
//						}
//						
//						onCompletion(true, resp, "Ok")
//					}
//					
//				} else {
//					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
//				}
//		}
	}
}
