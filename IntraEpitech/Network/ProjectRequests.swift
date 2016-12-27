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
    
    func details(forProject project: Project, completion: @escaping (Result<Any?>) -> Void) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@&activity=%@", project.scolaryear!, project.codeModule!, project.codeInstance!, project.codeActi!)
        
        super.call("projectDetail", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                project.setDetails(dict: responseJSON)
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
    
    func files(forProject project: Project, completion: @escaping (Result<[File]>) -> Void) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@&activity=%@", project.scolaryear!, project.codeModule!, project.codeInstance!, project.codeActi!)
        
        super.call("projectFiles", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                var files = [File]()
            
                for tmp in responseJSON.arrayValue {
                    files.append(File(dict: tmp))
                }
                completion(Result.success(files))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
    
    func marks(forProject project: Project, completion: @escaping (Result<Any?>) -> Void) {
    
        let params = String(format: "?year=%@&module=%@&instance=%@&activity=%@", project.scolaryear!, project.codeModule!, project.codeInstance!, project.codeActi!)
        
        super.call("projectMarks", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                var resp = [Mark]()
                for tmp in responseJSON.arrayValue {
                    resp.append(Mark(little: tmp))
                }
                project.marks = resp
                completion(Result.success(nil))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching modules:  \(err)")
            }
        }
    }
}

let projectRequests = ProjectRequests()
