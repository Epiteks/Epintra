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
	case Success(AnyObject?)
	case Failure(type: Error, message: String?)
}

enum Error: ErrorType {
	case APIError
	case UnauthorizedByUser
	case AuthenticationFailure
}
