//
//  PlanningRequests.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 09/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation

import Foundation
import SwiftyJSON

class PlanningRequests: RequestManager {
    
    func getPlanning(for start: Date, end: Date, completion: @escaping (Result<[Planning]>) -> Void) {
        
        let parameters = String(format: "?&start=%@&end=%@", start.toAPIString(), end.toAPIString())
        
        super.call("planning", urlParams: parameters) { (response) in
            switch response {
            case .success(let responseJSON):
                var resp = [Planning]()
                for tmp in responseJSON.arrayValue {
                    resp.append(Planning(dict: tmp))
                }
                resp = resp.sorted {
                    if let startTimeFirst = $0.startTime, let startTimeSecond = $1.startTime {
                        return startTimeFirst < startTimeSecond
                    }
                    return false
                }
                completion(Result.success(resp))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching planning events:  \(err)")
            }
        }
    }

    func enter(token: String, for planning: Planning, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = planning.requestURLData()
        
        let parameters = ["token": token]
    
        super.call("tokenValidation", params: parameters, urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.info("Token registration response \(responseJSON)")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Enter token error : \(err)")
            }
        }
    }
    
    func register(toEvent event: Planning, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = event.requestURLData()
        
        super.call("subscribeEvent", urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.info("Subscribe event \(responseJSON)")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Register event error : \(err)")
            }
        }
    }
    
    func unregister(toEvent event: Planning, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = event.requestURLData()
        
        super.call("unsubscribeEvent", urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.info("Unsubscribe event \(responseJSON)")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Unregister event error : \(err)")
            }
        }
    }
    
}

let planningRequests = PlanningRequests()
