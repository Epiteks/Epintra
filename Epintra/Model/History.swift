//
//  History.swift
//  Epintra
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

/// History represents a notification on the Intranet
struct History {
	
	var title: String?
	var userName: String?
	var userPicture: String?
	var content: String?
	var date: Date?
	
	init(dict: JSON) {
		self.title = dict["title"].stringValue
		self.userName = dict["user"]["title"].stringValue
		self.userPicture = dict["user"]["picture"].stringValue
		self.content = dict["content"].stringValue
		self.date = dict["date"].stringValue.toDate()
	}
}
