//
//  MiscRequests.swift
//  Epintra
//
//  Created by Hugo SCHOCH on 17/02/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class MiscRequests: RequestManager {

	/*!
	Get current status of API
	*/
	func getAPIStatus(completion: @escaping (Result<Bool>) -> Void) {
		super.call("apiStatus") { (response) in
			switch response {
			case .success(let responseJSON):
				completion(Result.success(responseJSON["status"].boolValue))
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetAPIStatus:  \(err)")
			}
		}
	}

	/*!
	Get current status of intranet
	*/
	func getIntraStatus(completion: @escaping (Result<Bool>) -> Void) {
		super.call("intraStatus") { (response) in
			switch response {
			case .success(let responseJSON):
				completion(Result.success(responseJSON["status"].boolValue))
			case .failure(let err):
				completion(Result.failure(type: err.type, message: err.message))
				log.error("GetIntraStatus:  \(err)")
			}
		}
	}

}

let miscRequests = MiscRequests()
