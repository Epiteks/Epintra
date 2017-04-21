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

        // API status
        "apiStatus": NetworkCallData(endpoint: "/", method: .get, secured: false),
        "intraStatus": NetworkCallData(endpoint: "/status", method: .get, secured: false),

        // Authentication requests
        "authentication": NetworkCallData(endpoint: "/login", method: .post, secured: false), // Authenticates user

        // User data
        "userData": NetworkCallData(endpoint: "/user", method: .get, secured: true), // Get selected user data
        "userHistory": NetworkCallData(endpoint: "/infos", method: .get, secured: true), // Get user history
        "userFiles": NetworkCallData(endpoint: "/user/files", method: .get, secured: true), // Get user files
        "userFlags": NetworkCallData(endpoint: "/user/flags", method: .get, secured: true), // Get slected user flags
        "allPromos": NetworkCallData(endpoint: "", method: .get, secured: true), // Epirank, get all users for data

        // User photo
        "userPhoto": NetworkCallData(endpoint: "/photo", method: .get, secured: true), // Get URL of the user image

        // Epirank
        "epirank": NetworkCallData(endpoint: "/", method: .get, secured: false), // Epirank, get users data

        // Planning
        "planning": NetworkCallData(endpoint: "/planning", method: .get, secured: true), // Get planning between two dates
        "tokenValidation": NetworkCallData(endpoint: "/token", method: .post, secured: true), // Token validation
        "subscribeEvent": NetworkCallData(endpoint: "/event", method: .post, secured: true), // Register to planning event
        "subscribePersonalEvent": NetworkCallData(endpoint: "/planning", method: .post, secured: true), // Register to planning event
        "unsubscribeEvent": NetworkCallData(endpoint: "/event", method: .delete, secured: true), // Unregister to planning event,
        "unsubscribePersonalEvent": NetworkCallData(endpoint: "/planning", method: .delete, secured: true), // Unregister to planning event,
        "eventRegistered": NetworkCallData(endpoint: "/event/registered", method: .get, secured: true), // Get users registered to an event
        "eventDetails": NetworkCallData(endpoint: "/event/rdv", method: .get, secured: true), // Get event details like slots
        "subscribeSlot": NetworkCallData(endpoint: "/event/rdv", method: .post, secured: true), // Subscribe to a slot
        "unsubscribeSlot": NetworkCallData(endpoint: "/event/rdv", method: .delete, secured: true), // Unsubscribe from a slot

        // Modules
        "userModules": NetworkCallData(endpoint: "/modules", method: .get, secured: true), // Get modules registered
        "moduleDetails": NetworkCallData(endpoint: "/module", method: .get, secured: true), // Get module details
        "moduleUsersRegistered": NetworkCallData(endpoint: "/module/registered", method: .get, secured: true), // Get users registered on module

        // Projects
        "currentProjects": NetworkCallData(endpoint: "/projects", method: .get, secured: true), // Get current projects
        "projectDetail": NetworkCallData(endpoint: "/project", method: .get, secured: true), // Get project details
        "projectFiles": NetworkCallData(endpoint: "/project/files", method: .get, secured: true), // Get project linked files

        // Marks
        "allMarks": NetworkCallData(endpoint: "/marks", method: .get, secured: true), // Get all marks of user
        "projectMarks": NetworkCallData(endpoint: "/project/marks", method: .get, secured: true) // Get all marks of a project
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
