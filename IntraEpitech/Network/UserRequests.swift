//
//  UserRequests.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserRequests: RequestManager {
	
	/*!
	API call to authenticate the user and get his token if credentials are good.
	
	- parameter login:			user login
	- parameter password:		user password
	- parameter completion:	Request completion action
	*/
	func auth(_ login: String, password: String, completion: @escaping CompletionHandlerType) {
		
		super.call("authentication", params: ["login": login, "password": password]) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				
				if let token = responseJSON["token"].string {
					log.info("Token : \(token)")
					ApplicationManager.sharedInstance.token = token
					completion(Result.success(nil))
				}
				
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("Authentication : \(err)")
				break
			}
		}
	}
	
	/*!
	Get current user informations to fill the profile.
	Fills the user object in manager, the completion takes nil in param.
	Set the user planning semester to allow him to see his current calendar.
	- parameter completion: Request completion action
	*/
	func getCurrentUserData(_ completion: @escaping CompletionHandlerType) {
		
		let app = ApplicationManager.sharedInstance
		
		let param = "?login=" + app.currentLogin!
		
		super.call("userData", params: nil, urlParams: param) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				
				app.user = User(dict: responseJSON)
				app.lastUserApiCall = Date().timeIntervalSince1970
				app.planningSemesters[(app.user?.semester!)!] = true
				
				completion(Result.success(nil))
				
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetCurrentUserData : \(err)")
				break
			}
		}
	}
	
	/*!
	Get passed user data.
	Completion provides the user object.
	- parameter login:			wanted user
	- parameter completion:	Request completion action
	*/
	func getUserData(_ login: String, completion: @escaping CompletionHandlerType) {
		
		let param = "?login=" + login
		
		super.call("userData", params: nil, urlParams: param) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				let usr = User(dict: responseJSON)
				
				completion(Result.success(usr))
				
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetUserData : \(err)")
				break
			}
		}
	}
	
	/*!
	Get user history.
	Fills the history in manager, the completion takes nil in param.
	- parameter completion:	Request completion action
	*/
	func getHistory(_ completion: @escaping CompletionHandlerType) {
		
		let app = ApplicationManager.sharedInstance
		
		super.call("userHistory", params: nil) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				
				app.user?.fillHistory(responseJSON)
				completion(Result.success(nil))
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetHistory : \(err)")
				break
			}
		}
	}
	
	func getUserFlags(_ login: String, completion: @escaping CompletionHandlerType) {
		
		let params = "?login=" + login
		
		super.call("userFlags", urlParams: params) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				let flags = responseJSON["flags"]
				var resp = [Flags]()
				
				resp.append(Flags(name: "medal", dict: flags["medal"]))
				resp.append(Flags(name: "remarkable", dict: flags["remarkable"]))
				resp.append(Flags(name: "difficulty", dict: flags["difficulty"]))
				resp.append(Flags(name: "ghost", dict: flags["ghost"]))
				
				completion(Result.success(resp as AnyObject?))
				
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetUserFlags : \(err)")
				break
			}
		}
	}
	
	func getUserDocuments(_ completion: @escaping CompletionHandlerType) {
		
		let params = "?login=" +  (ApplicationManager.sharedInstance.user?.login)!
		
		super.call("userFiles", urlParams: params) { (response) in
			switch response {
			case .success(let res):
				
				let responseJSON = JSON(res!)
				let responseArray = responseJSON.arrayValue
				var resp = [File]()
				for tmp in responseArray {
					resp.append(File(dict: tmp))
				}
				completion(Result.success(resp as AnyObject?))
				
				break
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetUserDocuments : \(err)")
				break
			}
		}
	}
	
}

let userRequests = UserRequests()
