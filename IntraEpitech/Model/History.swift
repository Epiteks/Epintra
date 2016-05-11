//
//  History.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class History: NSObject {
	
	var _title :String?
	var _userName :String?
	var _userPicture :String?
	var _content :String?
	var _date :NSDate?
	
	init(dict :JSON) {
		
		super.init()
		
		_title = dict["title"].stringValue
		_userName = dict["user"]["title"].stringValue
		_userPicture = dict["user"]["picture"].stringValue
		_content = dict["content"].stringValue
		_date = dict["date"].stringValue.toDate()
		
		if (_userPicture != nil && (_userPicture?.characters.count)! > 0 && ApplicationManager.sharedInstance._downloadedImages![_userPicture!] == nil) {
			ImageDownloader.downloadFrom(link: _userPicture!) {}
		}
	}
}
