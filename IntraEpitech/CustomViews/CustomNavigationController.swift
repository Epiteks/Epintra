//
//  CustomNavigationController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationBar.isTranslucent = false
		
		// Dark Style
		self.navigationBar.barTintColor = UIUtils.backgroundColor()
		self.navigationBar.tintColor = UIColor.white
		self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		
		// White Style
//		self.navigationBar.tintColor = UIUtils.backgroundColor()
//		self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIUtils.backgroundColor()]
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
