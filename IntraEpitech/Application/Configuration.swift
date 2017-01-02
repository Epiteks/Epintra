//
//  Configuration.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

class Configuration {
	
	enum ConfigType {
		case dev, prod
	}

	/// Sets the application mode to use differents things if we are in DEV or PROD
	static let applicationMode: ConfigType = .dev
	
	// URL of the API
	static let apiURL = "https://epitech.hug33k.fr/intra"

	/// URL of users images
	static let profilePictureURL = "https://cdn.local.epitech.eu/userprofil/"
}

let configurationInstance = Configuration()
