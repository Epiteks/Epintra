//
//  KeychainUtil.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class KeychainUtil {
    
    /// Common Keychain errors available for throwing
    ///
    /// - failedToSaveData: Something went wrong when saving data
    enum KeychainUtilError: Error {
        case failedToSaveData
    }
    
    // Private identifiers for Keychain access
    private static let userEmailIdentifier = "userEmail"
    private static let userPasswordIdentifier = "userPassword"
    
    /// Save user credentials after log in successed.
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    /// - Throws: can throw when something went wrong when saving data
    class func saveCredentials(email: String, password: String) throws {
        
        if KeychainWrapper.standard.set(email, forKey: userEmailIdentifier) == false
            || KeychainWrapper.standard.set(password, forKey: userPasswordIdentifier) == false {
            throw KeychainUtilError.failedToSaveData
        }
    }
    
    /// Get user credentials if they exist
    ///
    /// - Returns: tuple containing email/password or nil if there is nothing
    class func getCredentials() -> (email: String, password: String)? {
        
        if let email = KeychainWrapper.standard.string(forKey: userEmailIdentifier),
            let password = KeychainWrapper.standard.string(forKey: userPasswordIdentifier) {
            return (email, password)
        }
        
        return nil
    }
    
    /// Delete saved credentials
    /// Used when the user wants to log out
    class func deleteCredentials() {
        
        KeychainWrapper.standard.removeObject(forKey: userEmailIdentifier)
        KeychainWrapper.standard.removeObject(forKey: userPasswordIdentifier)
        
    }
    
}
