//
//  ActionButton.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
	override func drawRect(rect: CGRect) {
		
		self.layer.cornerRadius = 3
		
		self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		self.setBackgroundImage(UIUtils.lightBackgroundColor().toImage(), forState: .Normal)
		
		self.layer.masksToBounds = true
	}
}
