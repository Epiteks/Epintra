//
//  CompletionHandlerType.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 20/08/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

typealias CompletionHandlerType = (Result) -> Void

enum Result {
	case success(AnyObject?)
	case failure(type: AppError, message: String?)
}

enum AppError: Error {
	case apiError
	case unauthorizedByUser
	case authenticationFailure
}
