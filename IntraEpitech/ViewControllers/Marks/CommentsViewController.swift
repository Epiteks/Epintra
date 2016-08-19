//
//  CommentsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {
	
	var mark :Mark?
	@IBOutlet weak var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Comments", comment: "")
		
		// Do any additional setup after loading the view.
		
		let str = (mark?.comment)!// + "\n\n" + (mark?.correcteur)!
		print(str)
		textView.text = str
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
