//
//  Requests.swift
//  Epintra
//
//  Created by Maxime Junger on 12/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Alamofire

struct Request {
	var endpoint: String! // Endpoint of the call
	var method: Alamofire.HTTPMethod! // post / patch / get / ...
	var secured: Bool! // Know if we need token or not
}

class Requests {
	
	static let routes = [

		// API status
		"apiStatus": Request(endpoint: "/", method: .get, secured: false),
		"intraStatus": Request(endpoint: "/status", method: .get, secured: false),

		// Authentication requests
		"authentication": Request(endpoint: "/login", method: .post, secured: false), // Authenticates user
		
		// User data
		"userData": Request(endpoint: "/user", method: .get, secured: true), // Get selected user data
		"userHistory": Request(endpoint: "/infos", method: .get, secured: true), // Get user history
		"userFiles": Request(endpoint: "/user/files", method: .get, secured: true), // Get user files
		"userFlags": Request(endpoint: "/user/flags", method: .get, secured: true), // Get slected user flags
		"allPromos": Request(endpoint: "", method: .get, secured: true), // Epirank, get all users for data
		
		// Epirank
		"epirank": Request(endpoint: "/", method: .get, secured: false), // Epirank, get users data
		
		// Planning
		"planning": Request(endpoint: "/planning", method: .get, secured: true), // Get planning between two dates
		"tokenValidation": Request(endpoint: "/token", method: .post, secured: true), // Token validation
		"subscribeEvent": Request(endpoint: "/event", method: .post, secured: true), // Register to planning event
        "subscribePersonalEvent": Request(endpoint: "/planning", method: .post, secured: true), // Register to planning event
		"unsubscribeEvent": Request(endpoint: "/event", method: .delete, secured: true), // Unregister to planning event,
        "unsubscribePersonalEvent": Request(endpoint: "/planning", method: .delete, secured: true), // Unregister to planning event,
		"eventRegistered": Request(endpoint: "/event/registered", method: .get, secured: true), // Get users registered to an event
		"eventDetails": Request(endpoint: "/event/rdv", method: .get, secured: true), // Get event details like slots
		"subscribeSlot": Request(endpoint: "/event/rdv", method: .post, secured: true), // Subscribe to a slot
		"unsubscribeSlot": Request(endpoint: "/event/rdv", method: .delete, secured: true), // Unsubscribe from a slot
		
		// Modules
		"userModules": Request(endpoint: "/modules", method: .get, secured: true), // Get modules registered
		"moduleDetails": Request(endpoint: "/module", method: .get, secured: true), // Get module details
		"moduleUsersRegistered": Request(endpoint: "/module/registered", method: .get, secured: true), // Get users registered on module
		
		// Projects
		"currentProjects": Request(endpoint: "/projects", method: .get, secured: true), // Get current projects
		"projectDetail": Request(endpoint: "/project", method: .get, secured: true), // Get project details
		"projectFiles": Request(endpoint: "/project/files", method: .get, secured: true), // Get project linked files
		
		// Marks
		"allMarks": Request(endpoint: "/marks", method: .get, secured: true), // Get all marks of user
		"projectMarks": Request(endpoint: "/project/marks", method: .get, secured: true) // Get all marks of a project
		]
	
}
