//
//  Network.swift
//  Epintra
//
//  Created by Maxime Junger on 19/04/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import SystemConfiguration

/// Network interactions
class Network {

    static let alamofireManager: SessionManager = Network.initManager()

    class func initManager() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10

        return SessionManager(configuration: configuration)
    }

    /// Data needed to perform a request
    struct NetworkCallData {
        var endpoint: String
        var method: Alamofire.HTTPMethod
        var secured: Bool
    }

    /// Routes available in API
    static let routes: [String: NetworkCallData] = [

        // Authentication requests
        "authentication": NetworkCallData(endpoint: "/token", method: .post, secured: false), // Authenticate user
        
    ]

    /// Calling MARQUIS API with specified data
    ///
    /// - Parameters:
    ///   - data: data needed to perform the action (endpoint...)
    ///   - parameters: body parameters
    ///   - urlParameters: url parameters to add
    /// - Returns: Observable of result containing a JSON object
    class func call(data: NetworkCallData,
                    parameters: [String: Any]? = nil,
                    urlParameters: String? = nil) -> Observable<Result<JSON>> {

        return Observable.create { (observer) -> Disposable in

            var headers: [String: String]? = nil

            log.verbose("Request \(data.method) \(data.endpoint) with parameters :\n\t\(String(describing: parameters))\n\turlParams\n\t\(urlParameters ?? "")\n")

            // Check if call needs authentication, init headers
            if data.secured {
                headers = [String: String]()
                headers?["token"] = ApplicationManager.sharedInstance.token ?? ""
            }

            var newURL = Configuration.apiURL + data.endpoint

            if let urlParameters = urlParameters {
                if newURL.characters.last == "/" {
                    newURL += "\(urlParameters)"
                } else {
                    newURL += "?\(urlParameters)"
                }
            }

            Network.alamofireManager.request(newURL,
                                             method: data.method,
                                             parameters: parameters,
                                             encoding: JSONEncoding.default,
                                             headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            observer.onNext(Result.success(json))
                        } else {
                            observer.onNext(Result.success(JSON("")))
                        }
                    case .failure(let error):

                        //                        if error._code == NSURLErrorTimedOut {
                        //                            print("TIMEOUUUUUUUT")
                        //
                        //                        } else {
                        if let value = response.data {
                            let json = JSON(value)
                            log.error("An error occured with an API call. The result is \(json)")
                            observer.onNext(Result.failure(AppError(error: APIError.unknownAPIError, message: error.localizedDescription, statusCode: response.response?.statusCode ?? 0, jsonObject: json)))
                        } else {
                            observer.onNext(Result.failure(AppError(error: APIError.unknownAPIError, message: error.localizedDescription, statusCode: response.response?.statusCode ?? 0)))
                        }
                        //                        }
                    }
            }
            return Disposables.create()
        }
    }
}
