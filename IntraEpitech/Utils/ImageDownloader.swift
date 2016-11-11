//
//  ImageDownloader.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ImageDownloader: NSObject {
	
	class func downloadFrom(link:String, onCompletion :@escaping CompletionHandlerType ) {
		
		if (ApplicationManager.sharedInstance.canDownload == false) {
			onCompletion(Result.failure(type: AppError.unauthorizedByUser, message: ""))
			return
		}
		
		guard
			let url = URL(string: link)
			else {return}
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
				let data = data , error == nil,
				let image = UIImage(data: data)
				else {
					onCompletion(Result.failure(type: AppError.apiError, message: ""))
					return
			}
			DispatchQueue.main.async { () -> Void in
				ApplicationManager.sharedInstance.addImageToCache(link, image: image)
				onCompletion(Result.success(nil))
			}
		}).resume()
	}
	
	class func downloadFromCallback(link:String, onCompletion :@escaping (String) -> () ) {
		
		if (ApplicationManager.sharedInstance.canDownload == false) {
			onCompletion("")
			return
		}
		
		guard
			let url = URL(string: link)
			else {return}
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
			guard
				let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
				let data = data , error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async { () -> Void in
				ApplicationManager.sharedInstance.addImageToCache(link, image: image)
				onCompletion(link)
			}
		}).resume()
	}
	
	
	
}
