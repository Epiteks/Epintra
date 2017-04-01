//
//  KeychainUtil.swift
//  Epintra
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
    private static let credentialsKey = "userCredentials"

    /// Save user credentials after log in successed.
    ///
    /// - Parameter credentials: user credentials
    /// - Throws: can throw when something went wrong when saving data
    class func save(credentials: Authentication) throws {

        let data = NSKeyedArchiver.archivedData(withRootObject: credentials)

        if KeychainWrapper.standard.set(data, forKey: credentialsKey) == false {
            throw KeychainUtilError.failedToSaveData
        }
    }

    /// Get user credentials if they exist
    ///
    /// - Returns: authentication object or nil if there is nothing
    class func getCredentials() -> Authentication? {

        if let data = KeychainWrapper.standard.data(forKey: credentialsKey), let authentication = NSKeyedUnarchiver.unarchiveObject(with: data) as? Authentication {
            return authentication
        }
        return nil
    }

    /// Delete saved credentials
    /// Used when the user wants to log out
    class func deleteCredentials() {
        KeychainWrapper.standard.removeObject(forKey: credentialsKey)
    }

}
