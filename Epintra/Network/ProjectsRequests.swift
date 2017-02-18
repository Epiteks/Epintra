//
//  ProjectRequests.swift
//  Epintra
//
//  Created by Maxime Junger on 25/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectsRequests: RequestManager {
    
    func current(completion: @escaping (Result<[Project]>) -> Void) {
        super.call("currentProjects") { (response) in
            switch response {
            case .success(let responseJSON):
                var resp = [Project]()
                for tmp in responseJSON.arrayValue {
                    if (tmp["type_acti_code"].stringValue == "proj") {
                        resp.append(Project(dict: tmp))
                    }
                }
                completion(Result.success(resp))
                break
            case .failure(let err):
                completion(Result.failure(type: err.type, message: err.message))
                log.error("Fetching current projects:  \(err)")
            }
        }
    }
    
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
                log.error("Fetching project details:  \(err)")
            }
        }
    }
    
    func files(forProject project: Project, completion: @escaping (Result<[File]>) -> Void) {
        
        let params = String(format: "?year=%@&module=%@&instance=%@&activity=%@", project.scolaryear!, project.codeModule!, project.codeInstance!, project.codeActi!)
        
        super.call("projectFiles", urlParams: params) { response in
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
                log.error("Fetching project files:  \(err)")
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
                log.error("Fetching project marks:  \(err)")
            }
        }
    }
}

let projectsRequests = ProjectsRequests()
