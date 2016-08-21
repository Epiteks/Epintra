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
				logger.error(err)
				break
			}
		}
	}
	
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
	
	
}

let userRequests = UserRequests()
