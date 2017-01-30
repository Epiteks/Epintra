//
//  ProjectGroup.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectGroup {
	
	var title: String?
	var code: String?
	var finalNote: String?
	var master: User?
	var members: [User]?
	
	init(dict: JSON) {
		title = dict["title"].stringValue
		code = dict["code"].stringValue
		finalNote = dict["final_note"].stringValue
		master = User(dict: (dict["master"]))
		fillMembers(dict)
	}
	
	func fillMembers(_ dict: JSON) {
		
        self.members = [User]()
		
		let arr = dict["members"].arrayValue
		
		for tmp in arr {
			self.members?.append(User(little: tmp))
		}
	}
}
