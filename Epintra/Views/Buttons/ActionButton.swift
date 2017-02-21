//
//  ActionButton.swift
//  Epintra
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
	override func draw(_ rect: CGRect) {
		
		self.layer.cornerRadius = 3
		
		self.setTitleColor(UIColor.white, for: UIControlState())
		
		self.setBackgroundImage(UIUtils.lightBackgroundColor.toImage(), for: UIControlState())
		
		self.layer.masksToBounds = true
	}
}
