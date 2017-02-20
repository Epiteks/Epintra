//
//  ApplicationManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import RxSwift

class ApplicationManager {
    
    // Singleton
    internal static let sharedInstance = ApplicationManager()
    
    // Current token used for the calls
    internal var token: String?
    
//    private var userObservers = [Observer]()
    
    // Logged user
    internal var ouser: Variable<User>?
    internal var user: User?
    
    
//        didSet {
//            for observer in self.userObservers {
//                observer.function()
//            }
//        }

    // Calendar identifier
    internal var defaultCalendarIdentifier: String? {
        get {
           return UserPreferences.getDefaultCalendar()
        }
        set {
            // Save new selected calendar in preferences
            UserPreferences.saveDefaultCalendar(newValue)
        }
    }

    func resetInstance() {
        self.token = nil
        self.user = nil
//        self.userObservers.removeAll()
    }
    
    func addObserver() {
        
    }
}
