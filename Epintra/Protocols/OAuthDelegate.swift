//
//  OAuthDelegate.swift
//  Epintra
//
//  Created by Maxime Junger on 06/03/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation

protocol OAuthDelegate: class {
    func authentified(withEmail email: String?, andToken token: String?)
}
