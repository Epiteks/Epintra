//
//  WebViewViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var _webView: UIWebView!
    var _file :File?
    var _fileName :String?
    var _title :String?
    var _isUrl :Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if (_isUrl == true) {
            loadURL()
        }
        else {
            loadLocal()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: ("backButtonAction:"))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = nil
    }
    
    func backButtonAction(sender :AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func loadURL() {
        self.title = _file?._title!
        let url : NSURL! = NSURL(string: (_file?._url!)!)
        _webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func loadLocal() {
        self.title = _title!
        let htmlFile = NSBundle.mainBundle().pathForResource(_fileName, ofType: "html")
        do {
            let htmlString = try NSString.init(contentsOfFile: htmlFile!, encoding: NSUTF8StringEncoding)
            _webView.loadHTMLString(htmlString as String, baseURL: nil)
        }
        catch {}
        
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
