//
//  WebViewViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController, UIWebViewDelegate {
	
	@IBOutlet weak var webView: UIWebView!
	var file :File?
	var fileName :String?
	var pageTitle :String?
	var isUrl :Bool?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		if (isUrl == true) {
			loadURL()
		} else {
			loadLocal()
		}
	}
	
	func loadURL() {
		self.pageTitle = file?.title!
		let url : URL! = URL(string: (file?.url!)!)
		webView.loadRequest(URLRequest(url: url))
	}
	
	func loadLocal() {
		self.pageTitle = title!
		let htmlFile = Bundle.main.path(forResource: fileName, ofType: "html")
		do {
			let htmlString = try NSString.init(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8.rawValue)
			webView.loadHTMLString(htmlString as String, baseURL: nil)
		} catch {}
		
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
