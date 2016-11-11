//
//  RequestManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class RequestManager: NSObject {
	
	func call(_ requestID: String, params: [String: Any]?, completion: @escaping CompletionHandlerType) {
		
		let req = Requests.routes[requestID]
		var parameters = params
		
		log.info("Request \(requestID) with parameters :\n\t\(params)\n")
		
		if req!.secured == true {
			if parameters == nil {
				parameters = [String: AnyObject]()
			}
			parameters!["token"] = ApplicationManager.sharedInstance.token! as AnyObject?
		}
		log.info(configurationInstance.apiURL)
		
		Alamofire.request((configurationInstance.apiURL + (req?.endpoint)!), method: (req?.method)!, parameters: parameters, encoding: JSONEncoding.default)
		//Alamofire.request(configurationInstance.apiURL + (req?.endpoint)!, method: (req?.method)!, parameters: parameters)
			//.validate(statusCode: 200..<300)
			.responseJSON { res in
				let st = res.response?.statusCode
				if res.response?.statusCode >= 200 && res.response?.statusCode < 300 {
					if let val = res.result.value {
						let responseJSON = JSON(val)
						completion(Result.success(responseJSON.object as AnyObject?))
					}
				} else {
					if let val = res.result.value {
						let responseJSON = JSON(val)
						if let errorDictionary = responseJSON["error"].dictionary {
							if let errorMessage = errorDictionary["message"]?.string {
								completion(Result.failure(type: AppError.authenticationFailure, message: errorMessage))
								
							}
						}
					} else {
						completion(Result.failure(type: AppError.authenticationFailure, message: nil))
					}
				}
		}
		
	}
	
}
