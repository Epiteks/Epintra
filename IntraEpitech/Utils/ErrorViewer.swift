//
//  ErrorViewer.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ErrorViewer: NSObject {
	
	class func errorShow(viewController :UIViewController, mess :String, onCompletion :() -> ()) {
		let _alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
		
		_alert.title = NSLocalizedString("Error", comment: "")
		_alert.message = mess
		
		let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { _ in
			onCompletion()
		}
		_alert.addAction(defaultAction)
		
		viewController.showViewController(_alert, sender: viewController)
	}
	
	class func errorPresent(viewController :UIViewController, mess :String, onCompletion :() -> ()) {
		let _alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
		
		_alert.title = NSLocalizedString("Error", comment: "")
		_alert.message = mess
		
		let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default) { _ in
			onCompletion()
		}
		_alert.addAction(defaultAction)
		
		viewController.presentViewController(_alert, animated: true) {}
	}
}
