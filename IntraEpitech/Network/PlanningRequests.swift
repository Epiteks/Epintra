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
//
////        Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "start": first, "end": last])
////            .responseJSON { response in
////                if (response.result.isSuccess) {
////                    let responseCall = JSON(response.result.value!)
////                    let errorDict = responseCall["error"].dictionaryValue
////                    var errorMessage: String?
////                    if (errorDict.count > 0) {
////                        errorMessage = (errorDict["message"]?.stringValue)
////                        errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
////                        onCompletion(false, nil, errorMessage!)
////                    } else {
//                        var planningMan = Dictionary<String, [Planning]>()
//                        
//                        var date = first.shortToDate()
//                        let lol = NSDate()
//                        
//                        // TODO
//                        /*
//                         while (date < last.shortToDate()) {
//                         planningMan[date.toAPIString()] = [Planning]()
//                         date = date.fs_date(byAddingDays: 1)
//                         }
//                         */
//                        
//                        for tmpPlanning in responseCall.arrayValue {
//                            let tmp = Planning(dict: tmpPlanning)
//                            
//                            if (planningMan[tmp.getOnlyDay()] == nil) {
//                                planningMan[tmp.getOnlyDay()] = [Planning]()
//                            }
//                            
//                            let allowedCalendars = ApplicationManager.sharedInstance.planningSemesters
//                            if (allowedCalendars[tmp.semester!] == true) {
//                                planningMan[tmp.getOnlyDay()]?.append(tmp)	
//                            }
//                        }
//                        onCompletion(true, planningMan, "")
//                    }
//                } else {
//                    onCompletion(false, nil, (response.result.error?.localizedDescription)!)
//                }
//        }
//    }
    
}

let planningRequests = PlanningRequests()
