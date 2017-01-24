//
//  CompletionHandlerType.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

enum Result<T> {
	case success(T)
	case failure(type: AppError, message: String?)
}

enum AppError: Error {
	case apiError
	case unauthorizedByUser
	case authenticationFailure
    
    // Calendar Errors
    case unauthorizedCalendar
}
