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
	var method: Alamofire.HTTPMethod! // post / patch / get / ...
	var description: String! // Description of the call
	var secured: Bool! // Know if we need token or not
}


class Requests {
	
	static let routes = [
		
		// Authentication requests
		"authentication": Request(endpoint: "/login", method: .post, description: "Authenticate user", secured: false),
		
		// User data
		"userData": Request(endpoint: "/user", method: .get, description: "get selected user data", secured: true),
		"userHistory": Request(endpoint: "/infos", method: .post, description: "get user history", secured: true),
		"userFiles": Request(endpoint: "/user/files", method: .get, description: "get user files", secured: true),
		"userFlags": Request(endpoint: "/user/flags", method: .get, description: "get user flags", secured: true),
		"allPromos": Request(endpoint: "", method: .get, description: "get all users for data, currently on other URL", secured: true),
		
		
		// Planning
		"planning": Request(endpoint: "/planning", method: .get, description: "get planning between two dates", secured: true),
		"tokenValidation": Request(endpoint: "/token", method: .post, description: "Token validation", secured: true),
		"subscribeEvent": Request(endpoint: "/event", method: .post, description: "Register to planning event", secured: true),
		"unsubscribeEvent": Request(endpoint: "/event", method: .delete, description: "Unregister to planning event", secured: true),
		"eventRegistered": Request(endpoint: "/event/registered", method: .get, description: "get users registered to an event", secured: true),
		"eventDetails": Request(endpoint: "/event/rdv", method: .get, description: "get event details like slots", secured: true),
		"subscribeSlot": Request(endpoint: "/event/rdv", method: .post, description: "Subscribe to a slot", secured: true),
		"unsubscribeSlot": Request(endpoint: "/event/rdv", method: .delete, description: "Subscribe to a slot", secured: true),
		
		
		// Modules
		"modulesRegistered": Request(endpoint: "/modules", method: .get, description: "get modules registered", secured: true),
		"moduleDetails": Request(endpoint: "/module", method: .get, description: "get module details", secured: true),
		"moduleUsersRegistered": Request(endpoint: "/module/registered", method: .get, description: "get users registered on module", secured: true),
		
		// Projects
		"currentProjects": Request(endpoint: "/projects", method: .get, description: "get current projects", secured: true),
		"projectDetail": Request(endpoint: "/project", method: .get, description: "get project details", secured: true),
		"projectFiles": Request(endpoint: "/project/files", method: .get, description: "get project linked files", secured: true),
		
		// Marks
		"allMarks": Request(endpoint: "/marks", method: .get, description: "get all marks of user", secured: true),
		"projectMarks": Request(endpoint: "/project/marks", method: .get, description: "get all marks of a project", secured: true),
		]
	
}
