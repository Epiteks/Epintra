//
//  ModulesRequests.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ModulesRequests: RequestManager {
   
    func usersModules(completion: @escaping (Result<[Module]>) -> ()) {

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
                log.error("Fetching modules : \(err)")
            }
        }
    }
}

let modulesRequests = ModulesRequests()
