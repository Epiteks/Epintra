//
//  Mark.swift
//  Epintra
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class Mark: BasicInformation {
	
	var titleModule: String?
	var title: String?
	var correcteur: String?
	var finalNote: String?
	var comment: String?
    var codeacti: String?
	var login: String?
	
	override init(dict: JSON) {
        
        super.init(dict: dict)
        
		titleModule = dict["titlemodule"].stringValue
		title = dict["title"].stringValue
		correcteur = dict["correcteur"].stringValue
		finalNote = dict["final_note"].stringValue
		comment = dict["comment"].stringValue
		codeacti = dict["codeacti"].stringValue
		login = dict["login"].stringValue
	}
	
	init(little: JSON) {
        super.init(dict: little)
		correcteur = little["grader"].stringValue
		finalNote = little["note"].stringValue
		login = little["login"].stringValue
		comment = little["comment"].stringValue
	}
}
