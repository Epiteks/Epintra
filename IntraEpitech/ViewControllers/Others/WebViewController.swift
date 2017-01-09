//
//  WebViewViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
	
    var webView: UIWebView!
	
    var file: File?
	var fileName: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .bottom
    
        self.view.backgroundColor = .white
        
        var webViewFrame = self.view.frame
        
        if let tabBarFrame = self.tabBarController?.tabBar.frame, let navBarFrame = self.navigationController?.navigationBar.frame {
            let height = self.view.frame.height - (navBarFrame.height + navBarFrame.origin.y + tabBarFrame.height)
            
            webViewFrame = CGRect(x: self.view.frame.origin.x,
                                  y: self.view.frame.origin.y,
                                  width: self.view.frame.width,
                                  height: height)
        }
        
        self.webView = UIWebView(frame: webViewFrame)
        
        self.view.addSubview(webView)
        
        if self.file != nil {
            loadURL()
        } else {
            loadLocal()
        }
	}

	func loadURL() {
		self.title = file?.title!

        if let urlString = file?.url {
            
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            
            let header = String(format: "PHPSESSID=%@", ApplicationManager.sharedInstance.token!)
            
            request.addValue(header, forHTTPHeaderField: "Cookie")
            request.httpMethod = "GET"
            
            webView.loadRequest(request)
        }
	}
	
	func loadLocal() {
		let htmlFile = Bundle.main.path(forResource: fileName, ofType: "html")
		do {
			let htmlString = try NSString.init(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8.rawValue)
			webView.loadHTMLString(htmlString as String, baseURL: nil)
		} catch {}
		
	}
	
}
