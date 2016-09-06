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
	func auth(login: String, password: String, completion: CompletionHandlerType) {
		
		super.call("authentication", params: ["login": login, "password": password]) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				
				if let token = responseJSON["token"].string {
					logger.info("Token : \(token)")
					ApplicationManager.sharedInstance.token = token
					completion(Result.Success(nil))
				}
				
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("Authentication : \(err)")
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
	func getCurrentUserData(completion: CompletionHandlerType) {
		
		let app = ApplicationManager.sharedInstance
		
		super.call("userData", params: ["user": app.currentLogin!]) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				
				app.user = User(dict: responseJSON)
				app.lastUserApiCall = NSDate().timeIntervalSince1970
				app.planningSemesters[(app.user?.semester!)!] = true
				
				completion(Result.Success(nil))
				
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("GetCurrentUserData : \(err)")
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
	func getUserData(login: String, completion: CompletionHandlerType) {
		
		super.call("userData", params: ["user": login]) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				let usr = User(dict: responseJSON)
				
				completion(Result.Success(usr))
				
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("GetUserData : \(err)")
				break
			}
		}
	}
	
	/*!
	Get user history.
	Fills the history in manager, the completion takes nil in param.
	- parameter completion:	Request completion action
	*/
	func getHistory(completion: CompletionHandlerType) {
		
		let app = ApplicationManager.sharedInstance
		
		super.call("userHistory", params: nil) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				
				app.user?.fillHistory(responseJSON)
				completion(Result.Success(nil))
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("GetHistory : \(err)")
				break
			}
		}
	}
	
	func getUserFlags(login: String, completion: CompletionHandlerType) {
		
		super.call("userFlags", params: ["login": login]) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				let flags = responseJSON["flags"]
				var resp = [Flags]()
				
				resp.append(Flags(name: "medal", dict: flags["medal"]))
				resp.append(Flags(name: "remarkable", dict: flags["remarkable"]))
				resp.append(Flags(name: "difficulty", dict: flags["difficulty"]))
				resp.append(Flags(name: "ghost", dict: flags["ghost"]))
				
				completion(Result.Success(resp))
				
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("GetUserFlags : \(err)")
				break
			}
		}
	}
	
	func getUserDocuments(completion: CompletionHandlerType) {
		
		super.call("userFiles", params: ["login": (ApplicationManager.sharedInstance.user?.login)!]) { (response) in
			switch response {
			case .Success(let res):
				
				let responseJSON = JSON(res!)
				let responseArray = responseJSON.arrayValue
				var resp = [File]()
				for tmp in responseArray {
					resp.append(File(dict: tmp))
				}
				completion(Result.Success(resp))
				
				break
			case .Failure(let err):
				completion(Result.Failure(type: err.type, message: err.message))
				logger.error("GetUserDocuments : \(err)")
				break
			}
		}
	}
	
}

let userRequests = UserRequests()
