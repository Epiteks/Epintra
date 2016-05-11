//
//  Mark.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Mark: NSObject {
	
	var _titleModule :String?
	var _title :String?
	var _correcteur :String?
	var _finalNote :String?
	var _comment :String?
	var _scolaryear :String?
	var _codemodule :String?
	var _codeinstance :String?
	var _codeacti :String?
	var _login :String?
	
	init(dict :JSON)
	{
		_titleModule = dict["titlemodule"].stringValue
		_title = dict["title"].stringValue
		_correcteur = dict["correcteur"].stringValue
		_finalNote = dict["final_note"].stringValue
		_comment = dict["comment"].stringValue
		_scolaryear = dict["scolaryear"].stringValue
		_codemodule = dict["codemodule"].stringValue
		_codeinstance = dict["codeinstance"].stringValue
		_codeacti = dict["codeacti"].stringValue
		_login = dict["login"].stringValue
	}
	
	init(little :JSON)
	{
		_correcteur = little["grader"].stringValue
		_finalNote = little["note"].stringValue
		_login = little["login"].stringValue
		_comment = little["comment"].stringValue
	}
}
