//
//  UIImageViewExtensions.swift
//  Epintra
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {

	func cropToSquare() {
		// Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
		let contextImage: UIImage = UIImage(cgImage: self.image!.cgImage!)
		
		// Get the size of the contextImage
		let contextSize: CGSize = contextImage.size
		
		let posX: CGFloat
		let posY: CGFloat
		let width: CGFloat
		let height: CGFloat
		
		// Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
		if contextSize.width > contextSize.height {
			posX = ((contextSize.width - contextSize.height) / 2)
			posY = 0
			width = contextSize.height
			height = contextSize.height
		} else {
			posX = 0
			posY = ((contextSize.height - contextSize.width) / 2) - 10
			width = contextSize.width
			height = contextSize.width
		}
		
		let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
		
		// Create bitmap image from context using the rect
		let imageRef: CGImage = (contextImage.cgImage)!.cropping(to: rect)!
		
		// Create a new image based on the imageRef and rotate back to the original orientation
		let image: UIImage = UIImage(cgImage: imageRef, scale: self.image!.scale, orientation: self.image!.imageOrientation)
		
		self.image = image
		self.clipsToBounds = true
	}
	
	func toCircle() {
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIUtils.lightBackgroundColor.cgColor
		self.layer.cornerRadius = self.frame.size.height / 2
	}

    func downloadProfileImage(fromURL url: URL) {
        self.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "userProfile")) { [weak self] _ in
            DispatchQueue.main.async {
                self?.cropToSquare()
                self?.toCircle()
            }
        }
        self.toCircle()
        self.cropToSquare()
    }
}
