//
//  ApplicationManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ApplicationManager {
    
    // Singleton
    internal static let sharedInstance = ApplicationManager()
    
    // Current token used for the calls
    internal var token: String?
    
    // Logged user
    internal var user: User?

    // Calendar identifier
    internal var defaultCalendarIdentifier: String? {
        willSet {
            // Save new selected calendar in preferences
            UserPreferences.saveDefaultCalendar(newValue)
        }
    }
    
    // Realm manager instance
    let realmManager: RealmManager = RealmManager()
    
    func resetInstance() {
        token = nil
        user = nil
    }
}
