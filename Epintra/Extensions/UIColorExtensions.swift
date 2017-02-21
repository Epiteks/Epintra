//
//  UIColorExtensions.swift
//  Epintra
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

public extension UIColor {
	func toImage() -> UIImage {
		let rect:  CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context:  CGContext = UIGraphicsGetCurrentContext()!
		
		context.setFillColor(self.cgColor)
		context.fill(rect)
		
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	public convenience init?(hexString: String) {
		let r, g, b, a: CGFloat
		
		if hexString.hasPrefix("#") {
			let start = hexString.characters.index(hexString.startIndex, offsetBy: 1)
			let hexColor = hexString.substring(from: start)
			
			if hexColor.characters.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
					a = CGFloat(hexNumber & 0x000000ff) / 255
					
					self.init(red: r, green: g, blue: b, alpha: a)
					return
				}
			}
		}
		return nil
	}
}
