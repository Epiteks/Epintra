//
//  Util.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 21/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class Util: NSObject {
	class func getPath(_ fileName: String) -> String {
		
		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let fileURL = documentsURL.appendingPathComponent(fileName)
		
		return fileURL.path
	}
	
	class func copyFile(_ fileName: NSString) {
		let dbPath: String = getPath(fileName as String)
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: dbPath) {
			
			let documentsURL = Bundle.main.resourceURL
			let fromPath = documentsURL!.appendingPathComponent(fileName as String)
			
			var error : NSError?
			do {
				try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
			} catch let error1 as NSError {
				error = error1
			}
			let alert: UIAlertView = UIAlertView()
			if (error != nil) {
				alert.title = "Error Occured"
				alert.message = error?.localizedDescription
			} else {
				alert.title = "Successfully Copy"
				alert.message = "Your database copy successfully"
			}
			alert.delegate = nil
			alert.addButton(withTitle: "Ok")
			//alert.show()
		}
	}
	
	class func invokeAlertMethod(_ strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
		let alert: UIAlertView = UIAlertView()
		alert.message = strBody as String
		alert.title = strTitle as String
		alert.delegate = delegate
		alert.addButton(withTitle: "Ok")
		alert.show()
	}
	
}
