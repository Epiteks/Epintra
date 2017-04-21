//
//  UserRequests.swift
//  Epintra
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import RxSwift

class UsersRequests: RequestManager {
	
	/*!
	API call to authenticate the user and get his token if credentials are good.
	
	- parameter login:			user login
	- parameter password:		user password
	- parameter completion:	Request completion action
	*/
	class func auth(_ login: String, password: String) -> Observable<Result<String>> {

        return Network.call(data: Network.routes["authentication"]!, parameters: ["login": login, "password": password])
            .map({ result -> Result<String> in
                switch result {
                case .success(let json):
                    log.verbose("Response from API : \(json)")
                    let token = json["token"].stringValue
                    ApplicationManager.sharedInstance.token = token
                    ApplicationManager.sharedInstance.user = Variable<User>(User(login: login))
                    return Result.success(token)
                case .failure(var error):
                    switch error.statusCode ?? 0 {
                    case 401:
                        error.newType(type: APIError.AuthenticationError.wrongCredentials)
                    default:
                        break
                    }
                    return Result.failure(error)
                }
            })
	}
	
	/*!
	Get current user informations to fill the profile.
	Fills the user object in manager, the completion takes nil in param.
	Set the user planning semester to allow him to see his current calendar.
	- parameter completion: Request completion action
	*/
	func getCurrentUserData(_ completion: @escaping (Result<Any?>) -> Void) {

        let dispo = DisposeBag()
        var login: String?
        
        ApplicationManager.sharedInstance.user?.asObservable()
        .do(onNext: { usr in
            login = usr.login
        }).subscribe().addDisposableTo(dispo)
        
        let param = "?login=" + (login ?? "")
		
		super.call("userData", params: nil, urlParams: param) { (response) in
			switch response {
			case .success(let responseJSON):
                ApplicationManager.sharedInstance.user?.value = User(dict: responseJSON)
				completion(Result.success(nil))
			case .failure(let err):
				completion(Result.failure(err))
				log.error("GetCurrentUserData:  \(err)")
			}
		}
	}
	
	/*!
	Get passed user data.
	Completion provides the user object.
	- parameter login:			wanted user
	- parameter completion:	Request completion action
	*/
	func getUserData(_ login: String, completion: @escaping (Result<User>) -> Void) {
		
		let param = "?login=" + login
		
		super.call("userData", params: nil, urlParams: param) { (response) in
			switch response {
			case .success(let responseJSON):
				let usr = User(dict: responseJSON)
				completion(Result.success(usr))
			case .failure(let err):
				completion(Result.failure(err))
				log.error("GetUserData:  \(err)")
			}
		}
	}
	
	/*!
	Get user history.
	Fills the history in manager, the completion takes nil in param.
	- parameter completion:	Request completion action
	*/
	func getHistory(_ completion: @escaping (Result<Any?>) -> Void) {
		
		let app = ApplicationManager.sharedInstance
		
		super.call("userHistory", params: nil) { (response) in
			switch response {
			case .success(let responseJSON):
				app.user?.value.fillHistory(responseJSON)
                ApplicationManager.sharedInstance.user?.value.fillHistory(responseJSON)
				completion(Result.success(nil))
				
			case .failure(let err):
				completion(Result.failure(err))
				log.error("GetHistory:  \(err)")
				
			}
		}
	}
	
	func getUserFlags(_ login: String, completion: @escaping (Result<[Flags]>) -> Void) {
		
		let params = "?login=" + login
		
		super.call("userFlags", urlParams: params) { (response) in
			switch response {
			case .success(let responseJSON):
				let flags = responseJSON["flags"]
				var resp = [Flags]()
				
				resp.append(Flags(name: "medal", dict: flags["medal"]))
				resp.append(Flags(name: "remarkable", dict: flags["remarkable"]))
				resp.append(Flags(name: "difficulty", dict: flags["difficulty"]))
				resp.append(Flags(name: "ghost", dict: flags["ghost"]))
				completion(Result.success(resp))
			case .failure(let err):
				completion(Result.failure(err))
				log.error("GetUserFlags:  \(err)")
			}
		}
	}
	
	func getUserDocuments(_ completion: @escaping (Result<[File]>) -> Void) {
		
		let params = "?login=" +  (ApplicationManager.sharedInstance.user?.value.login)!
		
		super.call("userFiles", urlParams: params) { (response) in
			switch response {
			case .success(let responseJSON):
				let responseArray = responseJSON.arrayValue
				var resp = [File]()
				for tmp in responseArray {
					resp.append(File(dict: tmp))
				}
				completion(Result.success(resp))
				
			case .failure(let err):
				completion(Result.failure(err))
				log.error("GetUserDocuments:  \(err)")
				
			}
		}
    }
    
    func allMarks(_ completion: @escaping (Result<[Mark]>) -> Void) {
        
        super.call("allMarks") { (response) in
            switch response {
            case .success(let responseJSON):
                var resp = [Mark]()
                for tmp in responseJSON.arrayValue {
                    resp.insert(Mark(dict: tmp), at: 0)
                }
                completion(Result.success(resp))
            case .failure(let err):
                completion(Result.failure(err))
                log.error("Get all marks :  \(err)")
                
            }
        }
    }
    
    func download(students promo: String, withFilter filter: FilterRankViewController.RankFilter?, completion: @escaping (Result<Results<StudentInfo>?>) -> Void) {
        
        let params = String(format: "?promotion=%@&format=json", promo)
        
        super.call("epirank", urlParams: params) { (response) in
            switch response {
            case .success(let responseJSON):
                
                let updatedAtString = responseJSON["updatedAt"].stringValue
                
                var students = [StudentInfo]()
                
                for tmp in responseJSON["students"].arrayValue {
                    students.append(StudentInfo(dict: tmp, promo: promo))
                }
                DispatchQueue(label: "background").async {
                    do {
                        var realmStudentInfo = RealmStudentInfo()
                        
                        //var epirankInformation = realmStudentInfo.epirankInformation(forPromo: promo)
                        
                        //if epirankInformation == nil || epirankInformation?.promotion == nil || epirankInformation?.updatedAt == nil {
                        let epirankInformation = EpirankInformation(promo: promo, date: Date(fromEpirank: updatedAtString))
                        //}
                        try realmStudentInfo.save(students: students, updatedAt: epirankInformation)
                        
                        DispatchQueue.main.async {
                            // Need new thread
                            realmStudentInfo = RealmStudentInfo()
                            completion(Result.success(realmStudentInfo.students(byPromotion: promo, andCities: filter?.cities)))
                        }
                        
                    } catch {
                        log.error("Realm save failed")
                    }
                }
            case .failure(let err):
                completion(Result.failure(err))
                log.error("Get all marks :  \(err)")
                
            }
        }
    }

    class func getPhotoURL(_ login: String) -> Observable<Result<String>> {

        return Network.call(data: Network.routes["userPhoto"]!, urlParameters: "?login=\(login)")
            .map({ result -> Result<String> in
                switch result {
                case .success(let json):
                    return Result.success(json["url"].stringValue)
                case .failure(let error):
                    return Result.failure(error)
                }
            })
    }
}

let usersRequests = UsersRequests()
