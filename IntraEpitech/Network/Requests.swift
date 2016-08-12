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
}


class Requests {

	static let routes = [

		// Authentication requests
		"authentication": Request(endpoint: "/login", method: .POST, description: "Authenticate user"),

		// User data
		"userData": Request(endpoint: "/user", method: .GET, description: "Get selected user data"),
		"userHistory": Request(endpoint: "/infos", method: .POST, description: "Get user history"),
		"userFiles": Request(endpoint: "/user/files", method: .GET, description: "Get user files"),
		"userFlags": Request(endpoint: "/user/flags", method: .GET, description: "Get user flags"),
		"allPromos": Request(endpoint: "", method: .GET, description: "Get all users for data, currently on other URL"),


		// Planning
		"planning": Request(endpoint: "/planning", method: .GET, description: "Get planning between two dates"),
		"tokenValidation": Request(endpoint: "/token", method: .POST, description: "Token validation"),
		"subscribeEvent": Request(endpoint: "/event", method: .POST, description: "Register to planning event"),
		"unsubscribeEvent": Request(endpoint: "/event", method: .DELETE, description: "Unregister to planning event"),
		"eventRegistered": Request(endpoint: "/event/registered", method: .GET, description: "Get users registered to an event"),
		"eventDetails": Request(endpoint: "/event/rdv", method: .GET, description: "Get event details like slots"),
		"subscribeSlot": Request(endpoint: "/event/rdv", method: .POST, description: "Subscribe to a slot"),
		"unsubscribeSlot": Request(endpoint: "/event/rdv", method: .DELETE, description: "Subscribe to a slot"),


		// Modules
		"modulesRegistered": Request(endpoint: "/modules", method: .GET, description: "Get modules registered"),
		"moduleDetails": Request(endpoint: "/module", method: .GET, description: "Get module details"),
		"moduleUsersRegistered": Request(endpoint: "/module/registered", method: .GET, description: "Get users registered on module"),

		// Projects
		"currentProjects": Request(endpoint: "/projects", method: .GET, description: "Get current projects"),
		"projectDetail": Request(endpoint: "/project", method: .GET, description: "Get project details"),
		"projectFiles": Request(endpoint: "/project/files", method: .GET, description: "Get project linked files"),

		// Marks
		"allMarks": Request(endpoint: "/marks", method: .GET, description: "Get all marks of user"),
		"projectMarks": Request(endpoint: "/project/marks", method: .GET, description: "Get all marks of a project"),
		]

}
