//
//  ErrorViewer.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ErrorViewer: NSObject {
	
	class func errorShow(_ viewController :UIViewController, mess :String, onCompletion :@escaping () -> Void) {
		
		DispatchQueue.main.async {
			let _alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
			
			_alert.title = NSLocalizedString("Error", comment: "")
			_alert.message = mess
			
			let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { _ in
				onCompletion()
			}
			_alert.addAction(defaultAction)
			
			viewController.show(_alert, sender: viewController)
		}
	}
	
	class func errorPresent(_ viewController :UIViewController, mess :String, onCompletion :@escaping () -> Void) {
		
		DispatchQueue.main.async {
			
			if viewController.presentedViewController != nil {
				onCompletion()
				return
			}
			
			let _alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
			
			_alert.title = NSLocalizedString("Error", comment: "")
			_alert.message = mess
			
			let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { _ in
				onCompletion()
			}
			_alert.addAction(defaultAction)
			
			viewController.present(_alert, animated: true) {}
		}
	}
}
