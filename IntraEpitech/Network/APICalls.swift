//
//  APICalls.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class APICalls: NSObject {
	
	class func getApiUrl() -> String
	{
		return "http://epitech.hug33k.fr/"
		
		//		return "https://epitech-api.herokuapp.com/"
	}
	
	class func getRankingUrl() -> String
	{
		return "https://epitech.maximejunger.com/tek"
		
		//		return "https://epitech-api.herokuapp.com/"
	}
	
	class func getLocalUrl() -> String
	{
		return "192.168.0.28:80/"
	}
	
	class func getProfilePictureURL() -> String
	{
		return "https://cdn.local.epitech.eu/userprofil/"
	}
	
	class func getEpitechURL() -> String
	{
		return "https://intra.epitech.eu"
	}
	
}
