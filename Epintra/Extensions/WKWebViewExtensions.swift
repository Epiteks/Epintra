//
//  WKWebViewExtensions.swift
//  Epintra
//
//  Created by Maxime Junger on 06/03/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func load(urlString: String) -> WKNavigation? {
        guard let url = URL.init(string: urlString) else {
            return nil
        }
        return self.load(URLRequest(url: url))
    }
}
