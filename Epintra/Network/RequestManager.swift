//
//  RequestManager.swift
//  Epintra
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestManager {
    
    func call(_ requestID: String, params: [String: Any]? = nil, urlParams: String? = nil, completion: @escaping (Result<JSON>) -> Void) {
        
        let req = Requests.routes[requestID]
        var headers = [String: String]()
        var newURL = Configuration.apiURL + (req?.endpoint)!
        
        if req!.secured == true {
            headers["token"] = ApplicationManager.sharedInstance.token ?? ""
        }
        
        // Change URL Epirank
        if requestID == "epirank" {
            newURL = "https://epirank.junger.io/"
        }
        
        if (urlParams != nil) {
            newURL += urlParams!
        }
        
        if requestID != "authentication" {
            log.info("------\nRequest \(requestID) with parameters: \n\t\(String(describing: params))\n\tWith URL \(newURL)\n------")
        }
        
        Alamofire.request(newURL, method: (req?.method!)!, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { res in
                
                if res.response == nil || res.response?.statusCode == nil || res.result.isFailure {

                    completion(Result.failure(AppError(error: APIError.unknownAPIError,
                                                       message: res.result.error?.localizedDescription,
                                                       statusCode: res.response?.statusCode ?? nil)))
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
                            completion(Result.failure(AppError(error: APIError.unknownAPIError, message: errorMessage, statusCode: res.response?.statusCode ?? nil)))
                            
                        } else if let errorMessage = responseJSON["error"].string {
                            completion(Result.failure(AppError(error: APIError.unknownAPIError, message: errorMessage, statusCode: res.response?.statusCode ?? nil)))
                        } else {
                            completion(Result.failure(AppError(error: APIError.unknownAPIError, message: res.result.error?.localizedDescription, statusCode: res.response?.statusCode ?? nil)))
                        }
                    } else {
                        completion(Result.failure(AppError(error: APIError.unknownAPIError, message: res.result.error?.localizedDescription, statusCode: res.response?.statusCode ?? nil)))
                    }
                }
        }
    }

    class func downloadData(fromURL url: URL, completion: @escaping (Result<Data>) -> Void) {

        var headers = [String: String]()

        if let token = ApplicationManager.sharedInstance.token {
            headers["Cookie"] = "PHPSESSID=\(token)"
        }

        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .responseData { res in

                if let data = res.data {
                    completion(Result.success(data))
                } else {
                    completion(Result.failure(AppError(error: APIError.errorIntranetData, message: res.result.error?.localizedDescription, statusCode: res.response?.statusCode ?? nil)))
                }
        }
    }
}
