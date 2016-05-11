//
//  MarksApiCalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class MarksApiCalls: APICalls {
	
	class func getMarks(onCompletion :(Bool, [Mark]?, String) ->()) {
		
		let url = super.getApiUrl() + "marks"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						let arr = responseCall.arrayValue
						var resp = [Mark]()
						for tmp in arr {
							resp.insert(Mark(dict: tmp), atIndex: 0)
							//							resp.append(Mark(dict: tmp))
						}
						onCompletion(true, resp,  "Ok")
					}
					
				}
				else {
					print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectMarks(mark :Mark, onCompletion :(Bool, [Mark]?, String) ->()) {
		
		let url = super.getApiUrl() + "project/marks"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": mark._scolaryear!,
			"codemodule": mark._codemodule!,
			"codeinstance": mark._codeinstance!,
			"codeacti": mark._codeacti!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						let arr = responseCall.arrayValue
						var resp = [Mark]()
						for tmp in arr {
							resp.append(Mark(little: tmp))
						}
						onCompletion(true, resp,  "Ok")
					}
					
				}
				else {
					print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getProjectMarksForProject(proj :Project, onCompletion :(Bool, [Mark]?, String) ->()) {
		
		let url = super.getApiUrl() + "project/marks"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!,
			"scolaryear": proj._scolaryear!,
			"codemodule": proj._codeModule!,
			"codeinstance": proj._codeInstance!,
			"codeacti": proj._codeActi!])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						let arr = responseCall.arrayValue
						var resp = [Mark]()
						for tmp in arr {
							resp.append(Mark(little: tmp))
						}
						onCompletion(true, resp,  "Ok")
					}
					
				}
				else {
					print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	class func getMarksFor(user login :String, onCompletion :(Bool, [Mark]?, String) ->()) {
		
		let url = super.getApiUrl() + "marks"
		
		Alamofire.request(.GET, url, parameters: ["token": ApplicationManager.sharedInstance._token!, "login" :login])
			.responseJSON { response in
				if (response.result.isSuccess) {
					let responseCall = JSON(response.result.value!)
					let errorDict = responseCall["error"].dictionaryValue
					let errorMessage :String?
					if (errorDict.count > 0) {
						errorMessage = (errorDict["message"]?.stringValue)
						onCompletion(false, nil, errorMessage!)
					}
					else
					{
						let arr = responseCall.arrayValue
						var resp = [Mark]()
						for tmp in arr {
							resp.insert(Mark(dict: tmp), atIndex: 0)
							//							resp.append(Mark(dict: tmp))
						}
						onCompletion(true, resp,  "Ok")
					}
					
				}
				else {
					print("-----\(response.result.error?.debugDescription)")
					onCompletion(false, nil, (response.result.error?.localizedDescription)!)
				}
		}
	}
	
	
}
