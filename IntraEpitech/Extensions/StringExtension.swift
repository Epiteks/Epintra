//
//  StringExtension.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 16/11/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

extension String {
	
	func removeDomainEmailPart() -> String {

		if let index = self.characters.index(of: "@") {
			return self.substring(to: index)
		}
		
		return self
	}
	
}
