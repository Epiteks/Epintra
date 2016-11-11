//
//  UIImageViewExtensions.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

private var _imageAtIndexPath :IndexPath?

extension UIImageView {
	
	public var imageAtIndexPath : IndexPath {
		
		get {
			return _imageAtIndexPath!
		}
		
		set(newValue) {
			_imageAtIndexPath = newValue
			// What do you want to do here?
		}
	}
	
	func downloadedFrom(link:String, contentMode mode: UIViewContentMode) {
		guard
			let url = URL(string: link)
			else {return}
		contentMode = mode
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
				let data = data , error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async { () -> Void in
				self.image = image
				self.cropToSquare()
				self.clipsToBounds = true
			}
		}).resume()
	}
	
	func downloadFrom(link:String, contentMode mode: UIViewContentMode, onCompletion :@escaping (UIImage) -> ()) {
		guard
			let url = URL(string: link)
			else {return}
		contentMode = mode
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
				let data = data , error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async { () -> Void in
				//				self.image = image
				onCompletion(image)
				//self.cropToSquare()
				//self.clipsToBounds = true
			}
		}).resume()
	}
	
	
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
			posY = ((contextSize.height - contextSize.width) / 2)
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
		self.layer.borderColor = UIUtils.lightBackgroundColor().cgColor
		self.layer.cornerRadius = self.frame.size.height / 2
		
	}
}
