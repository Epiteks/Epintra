//
//  ProjectRequests.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectRequests: RequestManager {
    
    func details(forProject project: Project, completion: @escaping (Result<Any?>) -> ()) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@", project.scolaryear!, project.codeModule!, project.codeInstance!)
        
        super.call("projectDetail", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
              
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules : \(err)")
            }
        }
    }
}

let projectRequests = ProjectRequests()
