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
	
	var titleModule :String?
	var title :String?
	var correcteur :String?
	var finalNote :String?
	var comment :String?
	var scolaryear :String?
	var codemodule :String?
	var codeinstance :String?
	var codeacti :String?
	var login :String?
	
	init(dict :JSON) {
		titleModule = dict["titlemodule"].stringValue
		title = dict["title"].stringValue
		correcteur = dict["correcteur"].stringValue
		finalNote = dict["final_note"].stringValue
		comment = dict["comment"].stringValue
		scolaryear = dict["scolaryear"].stringValue
		codemodule = dict["codemodule"].stringValue
		codeinstance = dict["codeinstance"].stringValue
		codeacti = dict["codeacti"].stringValue
		login = dict["login"].stringValue
	}
	
	init(little :JSON) {
		correcteur = little["grader"].stringValue
		finalNote = little["note"].stringValue
		login = little["login"].stringValue
		comment = little["comment"].stringValue
	}
}
