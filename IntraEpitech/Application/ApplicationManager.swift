//
//  ApplicationManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ApplicationManager: NSObject {
	
	internal static let sharedInstance = ApplicationManager()
	
	internal var _token 		:String?
	internal var _user 			:User?
	internal var _currentLogin 	:String?
	internal var _downloadedImages :[String : UIImage]?
	internal var _canDownload 	:Bool?
	internal var _defaultCalendar :String?
	
	// DATA
	internal var _projects :[Project]?
	internal var _modules :[Module]?
	internal var _marks :[Mark]?
	internal var _allUsers :[User]?
	
	
	var _lastUserApiCall :Double?
	
	var _planningSemesters = [Bool]()
	
	override init() {
		super.init()
		_downloadedImages = [String : UIImage]()
		_canDownload = true
		_lastUserApiCall = 0
		fillPlanningSemesters()
	}
	
	func resetInstance() {
		_token = nil
		_user = nil
		_currentLogin = nil
		_lastUserApiCall = 0
	}
	
	func addImageToCache(url :String, image :UIImage) {
		if (_downloadedImages == nil) {
			_downloadedImages = [String : UIImage]()
		}
		_downloadedImages![url] = image
	}
	
	func fillPlanningSemesters() {
		_planningSemesters = [Bool]()
		
		if (UserPreferences.checkSemestersExist()) {
			_planningSemesters = UserPreferences.getSemesters()
			return 
		}
		
		_planningSemesters.append(true)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		_planningSemesters.append(false)
		
		if (_user != nil) {
			_planningSemesters[(_user?._semester!)!] = true
		}
	}
	
}
