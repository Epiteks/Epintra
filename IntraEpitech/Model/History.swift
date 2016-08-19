//
//  History.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import SwiftyJSON

class History: NSObject {
	
	var title :String?
	var userName :String?
	var userPicture :String?
	var content :String?
	var date :NSDate?
	
	init(dict :JSON) {
		
		super.init()
		
		title = dict["title"].stringValue
		userName = dict["user"]["title"].stringValue
		userPicture = dict["user"]["picture"].stringValue
		content = dict["content"].stringValue
		date = dict["date"].stringValue.toDate()
		
		if (userPicture != nil && (userPicture?.characters.count)! > 0 && ApplicationManager.sharedInstance.downloadedImages![userPicture!] == nil) {
			ImageDownloader.downloadFrom(link: userPicture!) {}
		}
	}
}
