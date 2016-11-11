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
	
	func authorize(_ onCompletion :@escaping (Bool) -> ()) {
		
		let authorizationStatus = ABAddressBookGetAuthorizationStatus()
		
		switch authorizationStatus {
		case .denied, .restricted:
			//1
			onCompletion(false)
		case .authorized:
			//2
			onCompletion(true)
		case .notDetermined:
			//3
			promptForAddressBookRequestAccess() { (res :Bool) in
				onCompletion(res)
			}
			
		}
	}
	
	func promptForAddressBookRequestAccess(_ onCompletion :@escaping (Bool) -> ()) {
		//let err: Unmanaged<CFError>? = nil
		ABAddressBookRequestAccessWithCompletion(addressBookRef) {
			(granted: Bool, error: CFError?) in
			DispatchQueue.main.async {
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
	
	func createUserRecord(_ usr: User) -> ABRecord {
		let usrRecord: ABRecord = ABPersonCreate().takeRetainedValue()
		ABRecordSetValue(usrRecord, kABPersonFirstNameProperty, usr.firstname as CFTypeRef!, nil)
		ABRecordSetValue(usrRecord, kABPersonLastNameProperty, usr.lastname as CFTypeRef!, nil)
		
		if (ApplicationManager.sharedInstance.canDownload == true) {
			let img = ApplicationManager.sharedInstance.downloadedImages![usr.imageUrl!]
			ABPersonSetImageData(usrRecord, UIImagePNGRepresentation(img!) as CFData!, nil)
		}
		return usrRecord
	}
	
}
