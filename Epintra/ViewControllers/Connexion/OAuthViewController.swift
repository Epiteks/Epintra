//
//  OAuthViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 06/03/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!

    let epitechPath = "https://intra.epitech.eu/"
    let office365 = "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=e05d4149-1624-4627-a5ba-7472a39e43ab&redirect_uri=https%3A%2F%2Fintra.epitech.eu%2Fauth%2Foffice365&state=%2F"
    var movedFromEpitechIntranet = false

    var epitechToken: String?
    var userEmail: String?

    let tokenRegexp = "(?<=PHPSESSID=)[^;]*"

    weak var oAuthDelegate: OAuthDelegate?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = self.webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.webView.load(urlString: self.epitechPath)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if let response = navigationResponse.response as? HTTPURLResponse, let fields = response.allHeaderFields as? [String: String] {
            if let token = getToken(fromHeaders: fields) {
                ApplicationManager.sharedInstance.token = token
                self.epitechToken = token
            }

        }

        if let urlSts = webView.url?.absoluteString, urlSts.contains("https://sts.epitech.eu/adfs/ls/") {
            let username = getQueryStringParameter(url: urlSts, param: "username")
            self.userEmail = username
            print("ehehehehehhe")



        }


        if webView.url?.absoluteString == epitechPath {
            if movedFromEpitechIntranet == false && self.epitechToken != nil {
                let url = URL.init(string: office365)
                let request = URLRequest(url: url!)
                webView.load(request)
                decisionHandler(.cancel)
                movedFromEpitechIntranet = true
                return
            } else {
                self.dismiss(animated: true, completion: {
                    self.oAuthDelegate?.authentified(withEmail: self.userEmail ?? "", andToken: self.epitechToken ?? "")
                })
            }
        }
        decisionHandler(.allow)
    }


    func getQueryStringParameter(url: String?, param: String) -> String? {
        if let url = url, let urlComponents = URLComponents(string: url), let queryItems = (urlComponents.queryItems) {
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }

    func getToken(fromHeaders headers: [String: String]) -> String? {
        if let cookiesSet = headers["Set-Cookie"], let range = cookiesSet.range(of:tokenRegexp, options: .regularExpression) {
            return cookiesSet.substring(with:range)
        }
        return nil
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
