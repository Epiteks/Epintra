//
//  PlanningApiCalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Alamofire
import SwiftyJSON

class PlanningApiCalls: APICalls {
	
	class func getPlanning(_ first :String, last :String, onCompletion :@escaping (Bool, Dictionary<String, [Planning]>?, String) ->()) {
		
		let url = super.getApiUrl() + "planning"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "start" :first, "end" :last])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						onCompletion(false, nil, errorMessage!)
					} else {
						var planningMan = Dictionary<String, [Planning]>()
						
						
						
						var date = first.shortToDate()
						let lol = NSDate()
						
						// TODO
						/*
						while (date < last.shortToDate()) {
							planningMan[date.toAPIString()] = [Planning]()
							date = date.fs_date(byAddingDays: 1)
						}
						*/
						
						for tmpPlanning in responseCall.arrayValue {
							let tmp = Planning(dict: tmpPlanning)
							
							if (planningMan[tmp.getOnlyDay()] == nil) {
								planningMan[tmp.getOnlyDay()] = [Planning]()
							}
							
							let allowedCalendars = ApplicationManager.sharedInstance.planningSemesters
							if (allowedCalendars[tmp.semester!] == true) {
								planningMan[tmp.getOnlyDay()]?.append(tmp)	
							}
						}
						onCompletion(true, planningMan, "")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func enterToken(_ planning :Planning, token :String, onCompletion :@escaping (Bool, String) ->()) {
		
		let url = super.getApiUrl() + "token"
		
		Alamofire.request(url, method: .post, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear" :planning.scolaryear!,
			"codemodule" :planning.codeModule!,
			"codeinstance" :planning.codeInstance!,
			"codeacti" :planning.codeActi!,
			"codeevent" :planning.codeEvent!,
			"tokenvalidationcode" :token])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						onCompletion(false, errorMessage)
					} else {
						onCompletion(true, NSLocalizedString("SuccessfullyValidated", comment: ""))
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func registerToEvent(_ planning :Planning, onCompletion :@escaping (Bool, String) ->()) {
		
		let url = super.getApiUrl() + "event"
		
		Alamofire.request(url, method: .post, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear" :planning.scolaryear!,
			"codemodule" :planning.codeModule!,
			"codeinstance" :planning.codeInstance!,
			"codeacti" :planning.codeActi!,
			"codeevent" :planning.codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						onCompletion(false, errorMessage)
					} else {
						onCompletion(true, NSLocalizedString("SuccessfullyRegistered", comment: ""))
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func unregisterToEvent(_ planning :Planning, onCompletion :@escaping (Bool, String) ->()) {
		
		let url = super.getApiUrl() + "event"
		
		Alamofire.request(url, method: .delete, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear" :planning.scolaryear!,
			"codemodule" :planning.codeModule!,
			"codeinstance" :planning.codeInstance!,
			"codeacti" :planning.codeActi!,
			"codeevent" :planning.codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						onCompletion(false, errorMessage)
					} else {
						onCompletion(true, NSLocalizedString("SuccessfullyUnregistered", comment: ""))
					}
				} else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getSpecialEvent(_ planning :Planning, onCompletion :@escaping (Bool, Planning?, String) ->()) {
		
		let url = super.getApiUrl() + "planning"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!, "start" :(planning.startTime?.toDate().toAPIString())!, "end" :(planning.startTime?.toDate().toAPIString())!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					} else {
						var res : Planning?
						for tmpPlanning in responseCall.arrayValue {
							let tmp = Planning(dict: tmpPlanning)
							
							if (tmp.startTime == "") {
								print("PUTAIN")
							}
							
							if (tmp.codeActi! == planning.codeActi! && tmp.codeEvent! == planning.codeEvent!) {
								res = tmp
								break
							}
						}
						onCompletion(true, res, "")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getStudentsRegistered(_ planning :Planning, onCompletion :@escaping (Bool, [RegisteredStudent]?, String) ->()) {
		
		let url = super.getApiUrl() + "event/registered"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": planning.scolaryear!,
			"codemodule" : planning.codeModule!,
			"codeinstance": planning.codeInstance!,
			"codeacti": planning.codeActi!,
			"codeevent": planning.codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					} else {
						var res = [RegisteredStudent]()
						
						for tmpUsers in responseCall.arrayValue {
							let tmp = RegisteredStudent(dict: tmpUsers)
							res.append(tmp)
						}
						onCompletion(true, res, "")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getEventDetails(_ planning :Planning, onCompletion :@escaping (Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		Alamofire.request(url, method: .get, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": planning.scolaryear!,
			"codemodule" : planning.codeModule!,
			"codeinstance": planning.codeInstance!,
			"codeacti": planning.codeActi!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					} else {
						
						let res = AppointmentEvent(dict: responseCall)
						res.eventStart = planning.startTime?.toDate()
						res.eventEnd = planning.endTime?.toDate()
						res.addAppointments(responseCall)
						onCompletion(true, res, "")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func subscribeToSlot(_ appointment :AppointmentEvent, slot :Appointment, onCompletion :@escaping (Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		let lastParamName = (appointment.groupId == "" ? "login" : "idteam")
		let lastParamValue = (appointment.groupId == "" ? ApplicationManager.sharedInstance.currentLogin! : appointment.groupId!)
		
		Alamofire.request(url, method: .post, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": appointment.scolaryear!,
			"codemodule" : appointment.codeModule!,
			"codeinstance": appointment.codeInstance!,
			"codeacti": appointment.codeActi!,
			"idcreneau": slot.id!,
			lastParamName: lastParamValue])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						let err = errorDict["message"]
						
						errorMessage = (err!.stringValue)
						
						if let dataFromString = errorMessage!.data(using: String.Encoding.utf8, allowLossyConversion: false) {
							let json = JSON(data: dataFromString)
							errorMessage = json["message"].stringValue
						}
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					} else {
						print(responseCall)
						onCompletion(true, nil, "")
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func unsubscribeToSlot(_ appointment :AppointmentEvent, slot :Appointment, onCompletion :@escaping (Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		let lastParamName = (appointment.groupId == "" ? "login" : "idteam")
		let lastParamValue = (appointment.groupId == "" ? ApplicationManager.sharedInstance.currentLogin! : appointment.groupId!)
		
		Alamofire.request(url, method: .delete, parameters: ["token": ApplicationManager.sharedInstance.token!,
			"scolaryear": appointment.scolaryear!,
			"codemodule" : appointment.codeModule!,
			"codeinstance": appointment.codeInstance!,
			"codeacti": appointment.codeActi!,
			"idcreneau": slot.id!,
			lastParamName: lastParamValue])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						let err = errorDict["message"]
						
						errorMessage = (err!.stringValue)
						
						if let dataFromString = errorMessage!.data(using: String.Encoding.utf8, allowLossyConversion: false) {
							let json = JSON(data: dataFromString)
							errorMessage = json["message"].stringValue
						}
						errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					} else {
						print(responseCall)
						let err = errorDict["message"]
						
					 
						errorMessage = (err!.stringValue)
						if (errorMessage != "") {
							if let dataFromString = errorMessage!.data(using: String.Encoding.utf8, allowLossyConversion: false) {
								let json = JSON(data: dataFromString)
								errorMessage = json["message"].stringValue
							}
							errorMessage = errorMessage!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
							
							onCompletion(false, nil, errorMessage!)
						} else {
							onCompletion(true, nil, "")
						}
					}
				} else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	
}
