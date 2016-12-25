//
//  Project.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
"num_event": null,
"type_acti_code": "proj",
"project": "Projet : EpiAndroid",
"codeinstance": "STG-5-1",
"scolaryear": "2015",
"acti_title": "EpiAndroid",
"title_module": "B5 - Java I Programming",
"end_event": null,
"code_location": "STG",
"begin_acti": "2015-12-28 00:00:00",
"codemodule": "B-PAV-560",
"type_acti": "Mini-Projets",
"codeacti": "acti-192058",
"end_acti": "2016-01-31 23:42:00",
"seats": null,
"registered": 1,
"num": "3",
"info_creneau": null,
"rights": [
"student"
],
"begin_event": null*/

class Project: NSObject {
	
	var typeActiCode :String?
	var projectName :String?
	var codeInstance :String?
	var scolaryear :String?
	var actiTitle :String?
	var titleModule :String?
	var beginActi :String?
	var codeModule :String?
	var codeActi :String?
	var endActi :String?
	var registered :Bool?
	var mark :String?
	
	init(dict :JSON) {
		
		typeActiCode = dict["type_acti_code"].stringValue
		projectName = dict["project"].stringValue
		codeInstance = dict["codeinstance"].stringValue
		scolaryear = dict["scolaryear"].stringValue
		actiTitle = dict["acti_title"].stringValue
		titleModule = dict["title_module"].stringValue
		beginActi = dict["begin_acti"].stringValue
		codeModule = dict["codemodule"].stringValue
		codeActi = dict["codeacti"].stringValue
		endActi = dict["end_acti"].stringValue
		registered = dict["registered"].boolValue
	}
	
	init(detail :JSON) {
		codeActi = detail["codeacti"].stringValue
		typeActiCode = detail["type_code"].stringValue
		actiTitle = detail["title"].stringValue
		titleModule = detail["module_title"].stringValue
		beginActi = detail["begin"].stringValue
		endActi = detail["end"].stringValue
		mark = detail["note"].stringValue
	}
}
