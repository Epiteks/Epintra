//
//  UIImageViewExtensions.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

private var _imageAtIndexPath :NSIndexPath?

extension UIImageView {
	
	public var imageAtIndexPath : NSIndexPath {
		
		get
		{
			return _imageAtIndexPath!
		}
		
		set(newValue)
		{
			_imageAtIndexPath = newValue
			// What do you want to do here?
		}
	}
	
	func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
		guard
			let url = NSURL(string: link)
			else {return}
		contentMode = mode
		NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
				let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
				let data = data where error == nil,
				let image = UIImage(data: data)
				else { return }
			dispatch_async(dispatch_get_main_queue()) { () -> Void in
				self.image = image
				self.cropToSquare()
				self.clipsToBounds = true
			}
		}).resume()
	}
	
	func downloadFrom(link link:String, contentMode mode: UIViewContentMode, onCompletion :(UIImage) -> ()) {
		guard
			let url = NSURL(string: link)
			else {return}
		contentMode = mode
		NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
				let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
				let data = data where error == nil,
				let image = UIImage(data: data)
				else { return }
			dispatch_async(dispatch_get_main_queue()) { () -> Void in
				//				self.image = image
				onCompletion(image)
				//self.cropToSquare()
				//self.clipsToBounds = true
			}
		}).resume()
	}
	
	
	func cropToSquare() {
		// Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
		let contextImage: UIImage = UIImage(CGImage: self.image!.CGImage!)
		
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
		
		let rect: CGRect = CGRectMake(posX, posY, width, height)
		
		// Create bitmap image from context using the rect
		let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
		
		// Create a new image based on the imageRef and rotate back to the original orientation
		let image: UIImage = UIImage(CGImage: imageRef, scale: self.image!.scale, orientation: self.image!.imageOrientation)
		
		self.image = image
		self.clipsToBounds = true
	}
	
	func toCircle() {
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIUtils.lightBackgroundColor().CGColor
		self.layer.cornerRadius = self.frame.size.height / 2
		
	}
	
	
}