//
//  UserPreferences.swift
//  Epintra
//
//  Created by Maxime Junger on 20/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import AVFoundation

class UserPreferences {
    
	/// Save user prefered calendar
	///
	/// - Parameter name: calendar id
	class func saveDefaultCalendar(_ name:  String?) {
		
		let def = UserDefaults.standard
        name == nil ? def.removeObject(forKey: "defaultCalendar") : def.set(name, forKey: "defaultCalendar")
        
	}
	
	/// Get user prefered calendar
	///
	/// - Returns: calendar id
	class func getDefaultCalendar() -> String? {
		
        let def = UserDefaults.standard
		return def.string(forKey: "defaultCalendar")
	
    }
	
	/// Get semesters the current user wants to display
	///
	/// - Returns: semesters array
	class func getSemesters() -> [Int]? {
	
        let def = UserDefaults.standard
		return def.array(forKey: "semesters") as? [Int]
    
    }
	
	/// Save the semesters the user wants to display
	///
	/// - Parameter data: semesters array
	class func saveSemesters(_ data:  [Int]) {
		
		let def = UserDefaults.standard
		def.set(data, forKey: "semesters")
        
	}
}
