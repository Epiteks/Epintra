//
//  File.swift
//  Epintra
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class File {
	
	var title: String?
	var url: String?
	
	init(dict: JSON) {
		
		title = dict["title"].stringValue
        
		url = Configuration.epitechURL + dict["fullpath"].stringValue
	}
	
}
