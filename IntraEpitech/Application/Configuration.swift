//
//  Configuration.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

open class Configuration {
	
	enum ConfigType {
		case dev, prod
	}
	
	/// Sets the application mode to use differents things if we are in DEV or PROD
	let applicationMode: ConfigType = .dev
	
	// URL of the API
	var apiURL: String {
		get {
			return "http://epitech.hug33k.fr/intra"
		}
	}
	
	var profilePictureURL: String {
		get {
			return "https://cdn.local.epitech.eu/userprofil/profilview/"
		}
	}
}

let configurationInstance = Configuration()
