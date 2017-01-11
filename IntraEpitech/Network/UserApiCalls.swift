//
//  UserApiCalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserApiCalls: APICalls {
	
	class func loginCall(_ login: String, password: String, onCompletion: @escaping (Bool, String) ->Void) {
		
		let url = super.getApiUrl() + "login"
		
		Alamofire.request(url, method: .post, parameters: ["login": login, "password": password])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let token = responseCall["token"].stringValue
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, errorMessage!)
					} else {
						print(token)
						onCompletion(true, token)
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getUserData(_ login: String, onCompletion: @escaping (Bool, String) ->Void) {
		
		let url = super.getApiUrl() + "user"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "user":  login])
			.responseJSON { response in
				if response.result.isSuccess {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, errorMessage!)
					} else {
						let app = ApplicationManager.sharedInstance
						app.user = User(dict: responseCall)
						app.lastUserApiCall = Date().timeIntervalSince1970
						//app.planningSemesters[(app.user?.semester!)!] = true
						onCompletion(true, "Ok")
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	class func getSelectedUserData(_ login: String, onCompletion: @escaping (Bool, User?, String) ->Void) {
		
		let url = super.getApiUrl() + "user"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "user":  login])
			.responseJSON { response in
				if response.result.isSuccess {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						let usr = User(dict: responseCall)
						onCompletion(true, usr, "Ok")
					}
				} else {
					
				}
		}
	}
	
	class func getUserHistory(_ onCompletion: @escaping (Bool, String) ->Void) {
		
		let url = super.getApiUrl() + "infos"
		
		Alamofire.request(url, method: .post, parameters: ["token": ApplicationManager.sharedInstance.token!])
			.responseJSON { response in
				if response.result.isSuccess {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, errorMessage!)
					} else {	
						ApplicationManager.sharedInstance.user?.fillHistory(responseCall)
						onCompletion(true, "Ok")
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getUserDocuments(_ onCompletion: @escaping (Bool, [File]?, String) ->Void) {
		
		let url = super.getApiUrl() + "user/files"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"login": (ApplicationManager.sharedInstance.user?.login)!])
			.responseJSON { response in
				if response.result.isSuccess {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						let arr = responseCall.arrayValue
						var resp = [File]()
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
	
	class func getUserFlags(_ login: String?, onCompletion: @escaping (Bool, [Flags]?, String) ->Void) {
		
		let url = super.getApiUrl() + "user/flags"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"login": login!])
			.responseJSON { response in
				if response.result.isSuccess {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage: String?
					if errorDict.count > 0 {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					} else {
						let flags = responseCall["flags"]
						var resp = [Flags]()
						
						resp.append(Flags(name: "medal", dict: flags["medal"]))
						resp.append(Flags(name: "remarkable", dict: flags["remarkable"]))
						resp.append(Flags(name: "difficulty", dict: flags["difficulty"]))
						resp.append(Flags(name: "ghost", dict: flags["ghost"]))
						
						onCompletion(true, resp, "Ok")
					}
				} else {
					
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getAllUsers(_ onCompletion: @escaping (Bool, [StudentInfo]?, String) ->Void) {
		
//		let url = super.getRankingUrl()
//		
//		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
//			"login": (ApplicationManager.sharedInstance.user?.login)!])
//			.responseJSON { response in
//				if response.result.isSuccess {
//					let responseCall = JSON(response.result.value!)
//					let errorDict = responseCall["error"].dictionaryValue
//					let errorMessage: String?
//					if errorDict.count > 0 {
//						errorMessage = (errorDict["message"]?.stringValue)
//						onCompletion(false, nil, errorMessage!)
//					} else {
//						
//						var resp = [StudentInfo]()
//						let db = DBManager.getInstance()
//						db.cleanStudentData()
//						resp = UserApiCalls.addPromo("tech1", responseCall: responseCall, arr: resp)
//						resp = UserApiCalls.addPromo("tech2", responseCall: responseCall, arr: resp)
//						resp = UserApiCalls.addPromo("tech3", responseCall: responseCall, arr: resp)
//						resp = UserApiCalls.addPromo("tech4", responseCall: responseCall, arr: resp)
//						resp = UserApiCalls.addPromo("tech5", responseCall: responseCall, arr: resp)
//						onCompletion(true, resp, "Ok")
//					}
//				} else {
//					
//					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
//				}
//		}
	}
	
//	class func addPromo(_ name: String, responseCall: JSON, arr: [StudentInfo]) -> [StudentInfo] {
//		var arr = arr
//		let db = DBManager.getInstance()
//		let tek = responseCall[name].arrayValue
//		
//		for tmp in tek {
//			let stud = StudentInfo(dict: tmp, promo: name)
//			arr.append(stud)
//			db.addStudentData(stud)
//		}
//		return arr
//	}
}
