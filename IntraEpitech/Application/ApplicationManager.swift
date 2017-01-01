//
//  ApplicationManager.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

/*let logger = Logger(formatter: Log.Formatter("%@: %@", .level, .message),
                 theme:     .TomorrowNightEighties,
                 minLevel:  .info)
*/
class ApplicationManager: NSObject {

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

	var planningSemesters = [Bool]()

	override init() {
		super.init()
		downloadedImages = [String:  UIImage]()
		canDownload = true
		lastUserApiCall = 0
		fillPlanningSemesters()
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

	func fillPlanningSemesters() {
		planningSemesters = [Bool]()

		if UserPreferences.checkSemestersExist() {
			planningSemesters = UserPreferences.getSemesters()
			return
		}

		planningSemesters.append(true)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)
		planningSemesters.append(false)

		if user != nil {
			planningSemesters[(user?.semester!)!] = true
		}
	}

}
