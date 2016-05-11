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
	
	class func getPlanning(first :String, last :String, onCompletion :(Bool, Dictionary<String, [Planning]>?, String) ->()) {
		
		let url = super.getApiUrl() + "planning"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!, "start" :first, "end" :last])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						var planningMan = Dictionary<String, [Planning]>()
						
						
						
						var date = first.shortToDate()
						
						while (date.earlierDate(last.shortToDate()) == date)
						{
							planningMan[date.toAPIString()] = [Planning]()
							date = date.fs_dateByAddingDays(1)
						}
						
						
						for tmpPlanning in responseCall.arrayValue
						{
							let tmp = Planning(dict: tmpPlanning)
							
							if (planningMan[tmp.getOnlyDay()] == nil)
							{
								planningMan[tmp.getOnlyDay()] = [Planning]()
							}
							
							let allowedCalendars = ApplicationManager.sharedInstance._planningSemesters
							if (allowedCalendars[tmp._semester!] == true) {
								planningMan[tmp.getOnlyDay()]?.append(tmp)	
							}
						}
						onCompletion(true, planningMan, "")
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func enterToken(planning :Planning, token :String, onCompletion :(Bool, String) ->()) {
		
		let url = super.getApiUrl() + "token"
		
		Alamofire.request(.POST, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear" :planning._scolaryear!,
			"codemodule" :planning._codeModule!,
			"codeinstance" :planning._codeInstance!,
			"codeacti" :planning._codeActi!,
			"codeevent" :planning._codeEvent!,
			"tokenvalidationcode" :token])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						onCompletion(false, errorMessage)
					}
					else
					{
						onCompletion(true, NSLocalizedString("SuccessfullyValidated", comment: ""))
					}
				}
				else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func registerToEvent(planning :Planning, onCompletion :(Bool, String) ->()) {
		
		let url = super.getApiUrl() + "event"
		
		Alamofire.request(.POST, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear" :planning._scolaryear!,
			"codemodule" :planning._codeModule!,
			"codeinstance" :planning._codeInstance!,
			"codeacti" :planning._codeActi!,
			"codeevent" :planning._codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						onCompletion(false, errorMessage)
					}
					else
					{
						onCompletion(true, NSLocalizedString("SuccessfullyRegistered", comment: ""))
					}
				}
				else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func unregisterToEvent(planning :Planning, onCompletion :(Bool, String) ->()) {
		
		let url = super.getApiUrl() + "event"
		
		Alamofire.request(.DELETE, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear" :planning._scolaryear!,
			"codemodule" :planning._codeModule!,
			"codeinstance" :planning._codeInstance!,
			"codeacti" :planning._codeActi!,
			"codeevent" :planning._codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					var errorMessage = responseCall["error"].stringValue
					
					if (errorMessage.characters.count > 0) {
						errorMessage = errorMessage.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						onCompletion(false, errorMessage)
					}
					else
					{
						onCompletion(true, NSLocalizedString("SuccessfullyUnregistered", comment: ""))
					}
				}
				else {
					onCompletion(false, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getSpecialEvent(planning :Planning, onCompletion :(Bool, Planning?, String) ->()) {
		
		let url = super.getApiUrl() + "planning"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!, "start" :(planning._startTime?.toDate().toAPIString())!, "end" :(planning._startTime?.toDate().toAPIString())!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						var res : Planning?
						for tmpPlanning in responseCall.arrayValue
						{
							let tmp = Planning(dict: tmpPlanning)
							
							if (tmp._startTime == "") {
								print("PUTAIN")
							}
							
							if (tmp._codeActi! == planning._codeActi! && tmp._codeEvent! == planning._codeEvent!) {
								res = tmp
								break
							}
						}
						onCompletion(true, res, "")
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getStudentsRegistered(planning :Planning, onCompletion :(Bool, [RegisteredStudent]?, String) ->()) {
		
		let url = super.getApiUrl() + "event/registered"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": planning._scolaryear!,
			"codemodule" : planning._codeModule!,
			"codeinstance": planning._codeInstance!,
			"codeacti": planning._codeActi!,
			"codeevent": planning._codeEvent!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						var res = [RegisteredStudent]()
						
						for tmpUsers in responseCall.arrayValue
						{
							let tmp = RegisteredStudent(dict: tmpUsers)
							res.append(tmp)
						}
						onCompletion(true, res, "")
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getEventDetails(planning :Planning, onCompletion :(Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": planning._scolaryear!,
			"codemodule" : planning._codeModule!,
			"codeinstance": planning._codeInstance!,
			"codeacti": planning._codeActi!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						
						let res = AppointmentEvent(dict: responseCall)
						res._eventStart = planning._startTime?.toDate()
						res._eventEnd = planning._endTime?.toDate()
						res.addAppointments(responseCall)
						onCompletion(true, res, "")
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func subscribeToSlot(appointment :AppointmentEvent, slot :Appointment, onCompletion :(Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		let lastParamName = (appointment._groupId == "" ? "login" : "idteam")
		let lastParamValue = (appointment._groupId == "" ? ApplicationManager.sharedInstance._currentLogin! : appointment._groupId!)
		
		Alamofire.request(.POST, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": appointment._scolaryear!,
			"codemodule" : appointment._codeModule!,
			"codeinstance": appointment._codeInstance!,
			"codeacti": appointment._codeActi!,
			"idcreneau": slot._id!,
			lastParamName: lastParamValue])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						let err = errorDict["message"]
						
						errorMessage = (err!.stringValue)
						
						if let dataFromString = errorMessage!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
							let json = JSON(data: dataFromString)
							errorMessage = json["message"].stringValue
						}
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						print(responseCall)
						onCompletion(true, nil, "")
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func unsubscribeToSlot(appointment :AppointmentEvent, slot :Appointment, onCompletion :(Bool, AppointmentEvent?, String) ->()) {
		
		let url = super.getApiUrl() + "event/rdv"
		
		let lastParamName = (appointment._groupId == "" ? "login" : "idteam")
		let lastParamValue = (appointment._groupId == "" ? ApplicationManager.sharedInstance._currentLogin! : appointment._groupId!)
		
		Alamofire.request(.DELETE, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": appointment._scolaryear!,
			"codemodule" : appointment._codeModule!,
			"codeinstance": appointment._codeInstance!,
			"codeacti": appointment._codeActi!,
			"idcreneau": slot._id!,
			lastParamName: lastParamValue])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					var errorMessage :String?
					if (errorDict.count > 0) {
						let err = errorDict["message"]
						
						errorMessage = (err!.stringValue)
						
						if let dataFromString = errorMessage!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
							let json = JSON(data: dataFromString)
							errorMessage = json["message"].stringValue
						}
						errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
						
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						print(responseCall)
						let err = errorDict["message"]
						
					 
						errorMessage = (err!.stringValue)
						if (errorMessage != "") {
							if let dataFromString = errorMessage!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
								let json = JSON(data: dataFromString)
								errorMessage = json["message"].stringValue
							}
							errorMessage = errorMessage!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
							
							onCompletion(false, nil, errorMessage!)
						}
						else {
							onCompletion(true, nil, "")
						}
					}
				}
				else {
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	
}
