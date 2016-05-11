//
//  ContactsHelper.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 07/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import AddressBook

class ContactsHelper: NSObject {
	
	let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
	
	func authorize(onCompletion :(Bool) -> ()) {
		
		let authorizationStatus = ABAddressBookGetAuthorizationStatus()
		
		switch authorizationStatus {
		case .Denied, .Restricted:
			//1
			onCompletion(false)
		case .Authorized:
			//2
			onCompletion(true)
		case .NotDetermined:
			//3
			promptForAddressBookRequestAccess() { (res :Bool) in
				onCompletion(res)
			}
			
		}
	}
	
	func promptForAddressBookRequestAccess(onCompletion :(Bool) -> ()) {
		//let err: Unmanaged<CFError>? = nil
		ABAddressBookRequestAccessWithCompletion(addressBookRef) {
			(granted: Bool, error: CFError!) in
			dispatch_async(dispatch_get_main_queue()) {
				if !granted {
					print("Just denied")
					onCompletion(false)
				} else {
					print("Just authorized")
					onCompletion(true)
				}
			}
		}
	}
	
	func createUserRecord(usr: User) -> ABRecordRef {
		let usrRecord: ABRecordRef = ABPersonCreate().takeRetainedValue()
		ABRecordSetValue(usrRecord, kABPersonFirstNameProperty, usr._firstname, nil)
		ABRecordSetValue(usrRecord, kABPersonLastNameProperty, usr._lastname, nil)
		
		if (ApplicationManager.sharedInstance._canDownload == true) {
			let img = ApplicationManager.sharedInstance._downloadedImages![usr._imageUrl!]
			ABPersonSetImageData(usrRecord, UIImagePNGRepresentation(img!), nil)
		}
		return usrRecord
	}
	
}
