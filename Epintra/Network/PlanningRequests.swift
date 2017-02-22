//
//  PlanningRequests.swift
//  Epintra
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
                log.verbose("Token registration response \(responseJSON)")
                planning.allowToken = false
                planning.eventRegisteredStatus = "present"
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
        var endpointID = ""
        
        if event.calendarType == .all {
            endpointID = "subscribeEvent"
        } else {
            endpointID = "subscribePersonalEvent"
        }
        
        super.call(endpointID, urlParams: urlParameters) { response in
            switch response {
            case .success(_):
                event.eventRegisteredStatus = "registered"
                log.verbose("Subscribed event \(event)")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Register event error : \(err)")
            }
        }
    }
    
    func unregister(fromEvent event: Planning, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = event.requestURLData()
        var endpointID = ""
        
        if event.calendarType == .all {
            endpointID = "unsubscribeEvent"
        } else {
            endpointID = "unsubscribePersonalEvent"
        }
        
        super.call(endpointID, urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                event.eventRegisteredStatus = "false"
                log.verbose("Unsubscribe event \(responseJSON)")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Unregister event error : \(err)")
            }
        }
    }
    
    func getSlots(forEvent event: Planning, completion: @escaping (Result<AppointmentEvent>) -> Void) {
    
        let urlParameters = event.requestURLData()
    
        super.call("eventDetails", urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.verbose("Event slots : \(responseJSON)")
                
                let res = AppointmentEvent(dict: responseJSON, eventStart: event.startTime!, eventEnd: event.endTime!, eventCodeAsked: event.codeEvent!, planning: event)
                completion(Result.success(res))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Getting event slots error : \(err)")
            }
        }

    }
    
    func register(toSlot slot: Slot, forEvent event: AppointmentEvent, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = slot.requestURLData(forEvent: event)
        
        super.call("subscribeSlot", urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.verbose("Subscribed to slot  : \(responseJSON)")
                slot.master = RegisteredStudent(withName: ApplicationManager.sharedInstance.user?.value.login ?? "", andEmail: event.currentMasterEmail ?? "")
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Subscribe slot error : \(err)")
            }
        }
    }
    
    func unregister(fromSlot slot: Slot, forEvent event: AppointmentEvent, completion: @escaping (Result<Any?>) -> Void) {
        
        let urlParameters = slot.requestURLData(forEvent: event)
        
        super.call("unsubscribeSlot", urlParams: urlParameters) { response in
            switch response {
            case .success(let responseJSON):
                log.verbose("Unsubscribed from slot  : \(responseJSON)")
                slot.master = nil
                slot.members = nil
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Unsubscribe from slot error : \(err)")
            }
        }
    }
}

let planningRequests = PlanningRequests()
