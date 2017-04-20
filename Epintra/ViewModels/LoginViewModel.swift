//
//  LoginViewModel.swift
//  Epintra
//
//  Created by Maxime Junger on 19/04/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {

    /// User email
    var userEmail = Variable<String?>("")

    /// User password
    var userPassword = Variable<String?>("")

    /// Observable value that the login view controller must observe on.
    /// Is set each time we attempt to authenticate.
    var authResponse: Observable<Result<Any?>>?

    /// Boolean to know if we are authenticating
    var isAuthenticating = Variable<Bool>(false)

    /// Checks if the two validators are true.
    /// If so, returns true. Otherwise, false.
    /// User for the log in button, to set it enabled or not
    var isValid: Observable<Bool> {
        return Observable.combineLatest(self.emailValidation, self.passwordValidation) { $0 && $1 }
    }

    /// Valid email text if the regexp matches
    internal var emailValidation: Observable<Bool> {
        return self.userEmail.asObservable()
            .map {
                return ($0?.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .regularExpression) != nil)
            }
            .shareReplay(1)
    }

    /// Validates password if it has enough parameters
    internal var passwordValidation: Observable<Bool> {
        return self.userPassword.asObservable()
            .map { ($0?.characters.count ?? 0) >= 1 }
            .shareReplay(1)
    }

    /// Binds the authResponse to the action
    ///
    /// - Parameter action: tap
    func bindResponse(action: Observable<Void>) {

        let userInputs = Observable.combineLatest(self.userEmail.asObservable(), self.userPassword.asObservable()) { (email, password) -> (String, String) in
            return (email!, password!)
        }

        self.authResponse = action.withLatestFrom(userInputs)
            .flatMap { (email, password) ->  Observable<Result<Any?>> in
                self.isAuthenticating.value = true
                return UsersRequests.auth(email, password: password)
        }
    }

    func checkTokenValidity() {

    }

    func save(credentials: Authentication) throws {
        let auth = Authentication(fromCredentials: credentials.email, password: credentials.password)
        try KeychainUtil.save(credentials: auth)
    }

    func saveCurrentCredentials() throws {

        guard let email = self.userEmail.value, let password = self.userPassword.value else {
            log.error("Tried to save credentials without content")
            return
        }

        let auth = Authentication(fromCredentials: email, password: password)
        try KeychainUtil.save(credentials: auth)
    }
    
}
