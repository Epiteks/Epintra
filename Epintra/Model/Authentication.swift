//
//  Authentication.swift
//  Epintra
//
//  Created by Maxime Junger on 01/04/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation

/// Class used to authenticate user and save credentials data
class Authentication: NSObject, NSCoding {

    /// User email
    var email: String

    /// User password
    var password: String?

    /// Token value
    var token: String?

    private let emailKey = "userEmail"
    private let passwordKey = "userPassword"
    private let tokenKey = "userToken"

    init(fromCredentials email: String, password: String? = nil, token: String? = nil) {
        self.email = email
        self.password = password
        self.token = token
    }

    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: self.emailKey) as? String ?? ""
        self.password = aDecoder.decodeObject(forKey: self.passwordKey) as? String
        self.token = aDecoder.decodeObject(forKey: self.tokenKey) as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: self.emailKey)
        aCoder.encode(self.password, forKey: self.passwordKey)
        aCoder.encode(self.token, forKey: self.tokenKey)
    }
}
