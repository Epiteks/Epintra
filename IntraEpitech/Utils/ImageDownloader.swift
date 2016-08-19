//
//  ImageDownloader.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ImageDownloader: NSObject {
	
	class func downloadFrom(link link:String, onCompletion :() -> () ) {
		
		print(link)
		
		if (ApplicationManager.sharedInstance.canDownload == false) {
			onCompletion()
			return
		}
		
		guard
			let url = NSURL(string: link)
			else {return}
		NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
				let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
				let data = data where error == nil,
				let image = UIImage(data: data)
				else { return }
			dispatch_async(dispatch_get_main_queue()) { () -> Void in
				ApplicationManager.sharedInstance.addImageToCache(link, image: image)
				onCompletion()
			}
		}).resume()
	}
	
	class func downloadFromCallback(link link:String, onCompletion :(String) -> () ) {
		
		if (ApplicationManager.sharedInstance.canDownload == false) {
			onCompletion("")
			return
		}
		
		guard
			let url = NSURL(string: link)
			else {return}
		NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
				let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
				let data = data where error == nil,
				let image = UIImage(data: data)
				else { return }
			dispatch_async(dispatch_get_main_queue()) { () -> Void in
				ApplicationManager.sharedInstance.addImageToCache(link, image: image)
				onCompletion(link)
			}
		}).resume()
	}

	
	
}
