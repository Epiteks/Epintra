//
//  ModulesRequests.swift
//  Epintra
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ModulesRequests: RequestManager {
   
    func usersModules(completion: @escaping (Result<[Module]>) -> Void) {
        super.call("userModules") { (response) in
            switch response {
            case .success(let responseJSON):
                
                let arr = responseJSON.arrayValue
                var modules = [Module]()
                for module in arr {
                    modules.insert(Module(dict: module), at: 0)
                }
                completion(Result.success(modules))
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
    
    func details(forModule module: Module, completion: @escaping (Result<Any?>) -> Void) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@", module.scolaryear!, module.codeModule!, module.codeInstance!)
        
        super.call("moduleDetails", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                module.setAllData(detail: responseJSON)
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
    
    func registeredStudents(for module: Module, completion: @escaping (Result<[RegisteredStudent]>) -> Void) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@", module.scolaryear!, module.codeModule!, module.codeInstance!)
        
        super.call("moduleUsersRegistered", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                if let studentsJSONArray = responseJSON.array {
                    var students = [RegisteredStudent]()
                    for tmp in studentsJSONArray {
                        students.append(RegisteredStudent(dict: tmp))
                    }
                    completion(Result.success(students))
                }
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
}

let modulesRequests = ModulesRequests()
