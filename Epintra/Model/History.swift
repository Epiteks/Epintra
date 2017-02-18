//
//  History.swift
//  Epintra
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class History {
	
	var title: String?
	var userName: String?
	var userPicture: String?
	var content: String?
	var date: Date?
	
    init() {
        
    }
    
	init(dict: JSON) {
		title = dict["title"].stringValue
		userName = dict["user"]["title"].stringValue
		userPicture = dict["user"]["picture"].stringValue
		content = dict["content"].stringValue
		date = dict["date"].stringValue.toDate()
	}
}
