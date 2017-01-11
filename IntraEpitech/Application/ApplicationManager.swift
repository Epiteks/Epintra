//
//  ApplicationManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ApplicationManager {
    
    internal static let sharedInstance = ApplicationManager()
    
    internal var token: String?
    internal var user: User?
    internal var currentLogin: String?
    internal var downloadedImages: [String:  UIImage]?
    internal var canDownload: Bool?
    internal var defaultCalendar: String?
    
    var realmManager: RealmManager = RealmManager()
    
    // DATA
    internal var projects: [Project]?
    internal var modules: [Module]?
    internal var marks: [Mark]?
    internal var allUsers: [User]?
    
    var lastUserApiCall: Double?
    
    init() {
        downloadedImages = [String:  UIImage]()
        canDownload = true
        lastUserApiCall = 0
    }
    
    func resetInstance() {
        token = nil
        user = nil
        currentLogin = nil
        lastUserApiCall = 0
    }
    
    func addImageToCache(_ url: String, image: UIImage) {
        if downloadedImages == nil {
            downloadedImages = [String:  UIImage]()
        }
        downloadedImages![url] = image
    }
    
}
