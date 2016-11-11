//
//  UserPreferences.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import AVFoundation

class UserPreferences: NSObject {
	
	class func saveData(_ login : String, password : String) {
		
		let def = UserDefaults.standard
		
		def.set(login, forKey: "login")
		def.set(password, forKey: "password")
	}
	
	class func saveWantToDownloadImage(_ wants : Bool) {
		
		let def = UserDefaults.standard
		
		def.set(wants, forKey: "wantsDownloading")
	}
	
	class func checkIfWantsDownloadingExists() -> Bool {
		
		let def = UserDefaults.standard
		
		let wants = def.string(forKey: "wantsDownloading")
		
		if (wants == nil) {
			return false
		}
		return true
	}
	
	class func getWantsDownloading() -> Bool {
		let def = UserDefaults.standard
		
		return def.bool(forKey: "wantsDownloading")
	}
	
	
	class func getData() -> (login :String, password :String) {
		
		let def = UserDefaults.standard
		
		let log = def.string(forKey: "login")
		let pass = def.string(forKey: "password")
		
		return (log!, pass!)
	}
	
	class func checkIfDataExists() -> Bool {
		
		let def = UserDefaults.standard
		
		let login = def.string(forKey: "login")
		let password = def.string(forKey: "password")
		
		if (login == nil || password == nil) {
			return false
		}
		return true
	}
	
	class func deleteData() {
		
		let def = UserDefaults.standard
		
		def.removeObject(forKey: "login")
		def.removeObject(forKey: "password")
	}
	
	class func savDefaultCalendar(_ name : String) {
		
		let def = UserDefaults.standard
		
		def.set(name, forKey: "defaultCalendar")
	}
	
	class func checkIfDefaultCalendarExists() -> Bool {
		
		let def = UserDefaults.standard
		
		let wants = def.string(forKey: "defaultCalendar")
		
		if (wants == nil) {
			return false
		}
		return true
	}
	
	class func getDefaultCalendar() -> String {
		let def = UserDefaults.standard
		
		return def.string(forKey: "defaultCalendar")!
	}
	
	class func getSemesters() -> [Bool] {
		
		let def = UserDefaults.standard
		
		let dict = def.array(forKey: "semesters") as! [Bool]
		
		return dict
	}
	
	class func saveSemesters(_ data : [Bool]) {
		
		let def = UserDefaults.standard
		
		def.set(data, forKey: "semesters")
	}
	
	
	class func checkSemestersExist() -> Bool {
		
		let def = UserDefaults.standard
		
		let dict = def.array(forKey: "semesters")
		
		if (dict == nil) {
			return false
		}
		return true
	}
	
	class func deleteSemesters() {
		
		let def = UserDefaults.standard
		
		def.removeObject(forKey: "semesters")
	}
}
