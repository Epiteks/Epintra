//
//  Requests.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 12/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import Alamofire

struct Request {
	var endpoint: String! // Endpoint of the call
	var method: Alamofire.Method! // POST / PATCH / GET / ...
	var description: String! // Description of the call
	var secured: Bool! // Know if we need token or not
}


class Requests {
	
	static let routes = [
		
		// Authentication requests
		"authentication": Request(endpoint: "/login", method: .POST, description: "Authenticate user", secured: false),
		
		// User data
		"userData": Request(endpoint: "/user", method: .GET, description: "Get selected user data", secured: true),
		"userHistory": Request(endpoint: "/infos", method: .POST, description: "Get user history", secured: true),
		"userFiles": Request(endpoint: "/user/files", method: .GET, description: "Get user files", secured: true),
		"userFlags": Request(endpoint: "/user/flags", method: .GET, description: "Get user flags", secured: true),
		"allPromos": Request(endpoint: "", method: .GET, description: "Get all users for data, currently on other URL", secured: true),
		
		
		// Planning
		"planning": Request(endpoint: "/planning", method: .GET, description: "Get planning between two dates", secured: true),
		"tokenValidation": Request(endpoint: "/token", method: .POST, description: "Token validation", secured: true),
		"subscribeEvent": Request(endpoint: "/event", method: .POST, description: "Register to planning event", secured: true),
		"unsubscribeEvent": Request(endpoint: "/event", method: .DELETE, description: "Unregister to planning event", secured: true),
		"eventRegistered": Request(endpoint: "/event/registered", method: .GET, description: "Get users registered to an event", secured: true),
		"eventDetails": Request(endpoint: "/event/rdv", method: .GET, description: "Get event details like slots", secured: true),
		"subscribeSlot": Request(endpoint: "/event/rdv", method: .POST, description: "Subscribe to a slot", secured: true),
		"unsubscribeSlot": Request(endpoint: "/event/rdv", method: .DELETE, description: "Subscribe to a slot", secured: true),
		
		
		// Modules
		"modulesRegistered": Request(endpoint: "/modules", method: .GET, description: "Get modules registered", secured: true),
		"moduleDetails": Request(endpoint: "/module", method: .GET, description: "Get module details", secured: true),
		"moduleUsersRegistered": Request(endpoint: "/module/registered", method: .GET, description: "Get users registered on module", secured: true),
		
		// Projects
		"currentProjects": Request(endpoint: "/projects", method: .GET, description: "Get current projects", secured: true),
		"projectDetail": Request(endpoint: "/project", method: .GET, description: "Get project details", secured: true),
		"projectFiles": Request(endpoint: "/project/files", method: .GET, description: "Get project linked files", secured: true),
		
		// Marks
		"allMarks": Request(endpoint: "/marks", method: .GET, description: "Get all marks of user", secured: true),
		"projectMarks": Request(endpoint: "/project/marks", method: .GET, description: "Get all marks of a project", secured: true),
		]
	
}
