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

class RequestManager: NSObject {
	
	func call(requestID: String, params: [String: AnyObject]?, completion: CompletionHandlerType) {
		
		let req = Requests.routes[requestID]
		
		logger.info("Request \(requestID) with parameters :\n\(params)\n")
		
		Alamofire.request((req?.method)!, configurationInstance.apiURL + (req?.endpoint)!, parameters: params)
			//.validate(statusCode: 200..<300)
			.responseJSON { res in
				
				if res.response?.statusCode >= 200 && res.response?.statusCode < 300 {
					if let val = res.result.value {
						let responseJSON = JSON(val)
						completion(Result.Success(responseJSON.object))
					}
				} else {
					if let val = res.result.value {
						let responseJSON = JSON(val)
						if let errorDictionary = responseJSON["error"].dictionary {
							if let errorMessage = errorDictionary["message"]?.string {
								completion(Result.Failure(type: Error.AuthenticationFailure, message: errorMessage))
								
							}
						}
					} else {
						completion(Result.Failure(type: Error.AuthenticationFailure, message: nil))
					}
				}
		}
		
	}
	
}
