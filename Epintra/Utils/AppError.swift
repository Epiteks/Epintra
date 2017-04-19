//
//  CompletionHandlerType.swift
//  Epintra
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Result helps us to get if an action succeded or not.
///
/// - success: Action worked
/// - failure: Action failed
enum Result<T> {
    case success(T)
    case failure(AppError)
}

//enum AppError: Error {
//	case apiError
//	case unauthorizedByUser
//	case authenticationFailure
//    
//    // Calendar Errors
//    case unauthorizedCalendar
//    case noCalendarSelected
//    case calendarNotExists
//
//    // Intranet error
//    case errorIntranetData
//}

/// MARQUIS errors data.
struct AppError {

    /// Model for errors coming from the API
    struct APIResultError {

        var message: String

        init(fromJSON json: JSON?) {
            self.message = json?["error"].stringValue ?? ""
        }
    }

    var type: Error
    var message: String?
    var statusCode: Int?
    var apiResult: APIResultError?

    init(error: Error, message: String? = nil, statusCode: Int? = nil, jsonObject: JSON? = nil) {
        self.type = error
        self.message = message == nil ? NSLocalizedString(String(reflecting: type), comment: "") : message
        self.statusCode = statusCode
        self.apiResult = APIResultError(fromJSON: jsonObject)
    }

    /// Change the type of error and update its message
    ///
    /// - Parameter type: new error type
    mutating func newType(type: Error) {
        self.type = type
        self.message = NSLocalizedString(String(reflecting: type), comment: "")
    }
}

/// Possible API Errors
///
/// - unknownAPIError: Unknown error
/// - networkError: Something weird happened with the network
/// - valueNotFound: If the content provided by the API is wrong
enum APIError: Error {

    case unknownAPIError
    case networkError
    case valueNotFound

    /// Errors related to the authentication
    enum AuthenticationError: Error {
        case wrongCredentials
    }

    // Intranet error
    case errorIntranetData
}

enum CalendarError: Error {
    case unauthorizedCalendar
    case restricted
    case noCalendarSelected
    case calendarDoesNotExist
}
