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
	
	func call(_ requestID: String, params: [String: Any]? = nil, urlParams: String? = nil, completion: @escaping (Result<JSON>) -> Void) {
		
		let req = Requests.routes[requestID]
		var headers = [String: String]()
		var newURL = configurationInstance.apiURL + (req?.endpoint)!
		
		if req!.secured == true {
			headers["token"] = ApplicationManager.sharedInstance.token!
		}
		
		if (urlParams != nil) {
			newURL += urlParams!
		}
		
		log.info("Request \(requestID) with parameters: \n\t\(params)\n\tWith URL \(newURL)")
		
		Alamofire.request(newURL, method: (req?.method!)!, parameters: params, encoding: JSONEncoding.default, headers: headers)
			.responseJSON { res in
				
				if res.response == nil || res.response?.statusCode == nil {
					completion(Result.failure(type: AppError.apiError, message: nil))
					return
				}
				
				if (res.response?.statusCode)! >= 200 && (res.response?.statusCode)! < 300 {
					if let val = res.result.value {
						let responseJSON = JSON(val)
						completion(Result.success(responseJSON))
					}
				} else {
					if let val = res.result.value {
						let responseJSON = JSON(val)
                        if let errorDictionary = responseJSON["error"].dictionary, let errorMessage = errorDictionary["message"]?.string {
                            completion(Result.failure(type: AppError.apiError, message: errorMessage))
                        } else {
                            completion(Result.failure(type: AppError.apiError, message: nil))
						}
						
					} else {
						completion(Result.failure(type: AppError.apiError, message: nil))
					}
				}
		}
	}
}
