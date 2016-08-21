//
//  Configuration.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

public class Configuration {
	
	enum ConfigType {
		case DEV, PROD
	}
	
	/// Sets the application mode to use differents things if we are in DEV or PROD
	let applicationMode: ConfigType = .DEV
	
	// URL of the API
	var apiURL: String {
		get {
			return "http://epitech.hug33k.fr"
		}
	}
}

let configurationInstance = Configuration()
