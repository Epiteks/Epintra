//
//  UserPreferences.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import AVFoundation

class UserPreferences: NSObject {
	
	class func saveData(login : String, password : String) {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.setObject(login, forKey: "login")
		def.setObject(password, forKey: "password")
	}
	
	class func saveWantToDownloadImage(wants : Bool) {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.setObject(wants, forKey: "wantsDownloading")
	}
	
	class func checkIfWantsDownloadingExists() -> Bool {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let wants = def.stringForKey("wantsDownloading")
		
		if (wants == nil) {
			return false
		}
		return true
	}
	
	class func getWantsDownloading() -> Bool {
		let def = NSUserDefaults.standardUserDefaults()
		
		return def.boolForKey("wantsDownloading")
	}
	
	
	class func getData() -> (login :String, password :String) {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let log = def.stringForKey("login")
		let pass = def.stringForKey("password")
		
		return (log!, pass!)
	}
	
	class func checkIfDataExists() -> Bool {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let login = def.stringForKey("login")
		let password = def.stringForKey("password")
		
		if (login == nil || password == nil) {
			return false
		}
		return true
	}
	
	class func deleteData() {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.removeObjectForKey("login")
		def.removeObjectForKey("password")
	}
	
	class func savDefaultCalendar(name : String) {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.setObject(name, forKey: "defaultCalendar")
	}
	
	class func checkIfDefaultCalendarExists() -> Bool {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let wants = def.stringForKey("defaultCalendar")
		
		if (wants == nil) {
			return false
		}
		return true
	}
	
	class func getDefaultCalendar() -> String {
		let def = NSUserDefaults.standardUserDefaults()
		
		return def.stringForKey("defaultCalendar")!
	}
	
	class func getSemesters() -> [Bool] {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let dict = def.arrayForKey("semesters") as! [Bool]
		
		return dict
	}
	
	class func saveSemesters(data : [Bool]) {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.setObject(data, forKey: "semesters")
	}
	
	
	class func checkSemestersExist() -> Bool {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		let dict = def.arrayForKey("semesters")
		
		if (dict == nil) {
			return false
		}
		return true
	}
	
	class func deleteSemesters() {
		
		let def = NSUserDefaults.standardUserDefaults()
		
		def.removeObjectForKey("semesters")
	}
}
