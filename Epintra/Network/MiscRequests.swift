//
//  MiscRequests.swift
//  Epintra
//
//  Created by Hugo SCHOCH on 17/02/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

class MiscRequests: RequestManager {

	/*!
     Get current status of API
     */
    class func getAPIStatus() -> Observable<Result<Bool>> {

        return Network.call(data: Network.routes["apiStatus"]!)
            .map({ result -> Result<Bool> in
                switch result {
                case .success(let json):
                    guard let status = json["status"].bool else {
                        return Result.failure(AppError(error: APIError.apiDown))
                    }
                    return Result.success(status)
                case .failure(let error):
                    log.error("Get API Status : \(error)")
                    return Result.failure(error)
                }
            })
    }

	/*!
	Get current status of intranet
	*/
	class func getIntraStatus() -> Observable<Result<Bool>> {

        return Network.call(data: Network.routes["intraStatus"]!)
            .map({ result -> Result<Bool> in
                switch result {
                case .success(let json):
                    guard let status = json["status"].bool else {
                        return Result.failure(AppError(error: APIError.intraDown))
                    }
                    return Result.success(status)
                case .failure(let error):
                    log.error("Get Intra Status : \(error)")
                    return Result.failure(error)
                }
            })

	}

}

let miscRequests = MiscRequests()
