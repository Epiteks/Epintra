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
	
	var _typeActiCode :String?
	var _projectName :String?
	var _codeInstance :String?
	var _scolaryear :String?
	var _actiTitle :String?
	var _titleModule :String?
	var _beginActi :String?
	var _codeModule :String?
	var _codeActi :String?
	var _endActi :String?
	var _registered :Bool?
	var _noteActi :String?
	
	
	init(dict :JSON) {
		
		_typeActiCode = dict["type_acti_code"].stringValue
		_projectName = dict["project"].stringValue
		_codeInstance = dict["codeinstance"].stringValue
		_scolaryear = dict["scolaryear"].stringValue
		_actiTitle = dict["acti_title"].stringValue
		_titleModule = dict["title_module"].stringValue
		_beginActi = dict["begin_acti"].stringValue
		_codeModule = dict["codemodule"].stringValue
		_codeActi = dict["codeacti"].stringValue
		_endActi = dict["end_acti"].stringValue
		_registered = dict["registered"].boolValue
	}
	
	init(detail :JSON)
	{
		_codeActi = detail["codeacti"].stringValue
		_typeActiCode = detail["type_code"].stringValue
		_actiTitle = detail["title"].stringValue
		_titleModule = detail["module_title"].stringValue
		_beginActi = detail["begin"].stringValue
		_endActi = detail["end"].stringValue
		_noteActi = detail["note"].stringValue
	}
}
