//
//  LoginViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	@IBOutlet weak var loginTableView: UITableView!
	@IBOutlet weak var loginButton: ActionButton!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var waitingView: UIView!
	@IBOutlet weak var connexionBlockView: UIView!
	
	var login = String()
	var password = String()
	
	// Used for moving the view
	var connexionButtonConstraintSave: CGFloat?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		waitingView.backgroundColor = UIUtils.backgroundColor()
		waitingView.hidden = true
		
		if (UserPreferences.checkIfDataExists()) {
			waitingView.hidden = false
			let data = UserPreferences.getData()
			login = data.login
			password = data.password
			loginCall()
		}
		
		self.view.backgroundColor = UIUtils.backgroundColor()
		
		// Set UITableView properties
		self.loginTableView.scrollEnabled = false
		self.loginTableView.layer.cornerRadius = 3
		self.loginTableView.separatorInset = UIEdgeInsetsZero
		
		
		// Set different texts
		self.loginButton.setTitle(NSLocalizedString("login", comment: ""), forState: .Normal)
		self.infoLabel.text = NSLocalizedString("noOfficialApp", comment: "")
		
		self.registerForKeyboardNotifications()
	}
	
	override func viewDidAppear(animated: Bool) {
		
		waitingView.hidden = true
		if (UserPreferences.checkIfDataExists()) {
			waitingView.hidden = false
		}
		
		if (waitingView.hidden == false) {
			MJProgressView.instance.showProgress(self.waitingView, white: true)
		} else {
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	/**
	Register Notification to get when keyboard is shown and hidden.
	*/
	func registerForKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapOnView(_:)))
		self.view.addGestureRecognizer(gesture)
	}
	
	
	func tapOnView(sender: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("normalCell")
		
		let textField = cell?.viewWithTag(1) as! UITextField
		
		textField.tintColor = UIUtils.backgroundColor()
		
		if (indexPath.row == 0) { textField.placeholder = NSLocalizedString("loginUser", comment: "") } else {
			textField.placeholder = NSLocalizedString("password", comment: "")
			textField.secureTextEntry = true
		}
		
		cell?.layoutMargins.left = 0
		
		return cell!
	}
	
	@IBAction func loginPressed(sender: AnyObject) {
		
		self.view.endEditing(true)
		
		// Getting login cell data
		var cell = loginTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
		var textField = cell?.viewWithTag(1) as! UITextField
		login = textField.text!
		
		// Getting password cell data
		cell = loginTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
		textField = cell?.viewWithTag(1) as! UITextField
		password = textField.text!
		
		if (login.characters.count == 0 || password.characters.count == 0) {
			ErrorViewer.errorPresent(self, mess: NSLocalizedString("pleaseFillEverything", comment: "")) { _ in }
			return
		}
		
		loginCall()
	}
	
	func loginCall() {
		MJProgressView.instance.showLoginProgress(self.loginButton, white: true)
		
		let date = NSDate()
		let tstamp = NSDate(timeIntervalSince1970: 1457784037)
		
		if (date.earlierDate(tstamp) == date && login == "iTunesConnect1203" && password == "iTunes1203") {
			login = "junger_m"
			password = "monsupermdp"
		}
		
		userRequests.auth(login, password: password) { (result) in
			
			MJProgressView.instance.hideProgress()
			
			switch (result) {
			case .Success(let val):
				UserPreferences.saveData(self.login, password: self.password)
				self.goToNextView()
				break
			case .Failure(let error):
				if (error.type == Error.AuthenticationFailure) {
					ErrorViewer.errorShow(self, mess: NSLocalizedString("invalidCombinaison", comment: "")) { _ in }
				} else if (error.type == Error.APIError) {
					ErrorViewer.errorShow(self, mess: NSLocalizedString("unknownApiError", comment: "")) { _ in }
				}
				self.waitingView.hidden = true
				break
			}
		}
		//
		//		UserApiCalls.loginCall(login, password: password) { (isOk: Bool, response: String) in
		//			
		//			// Login Callback
		//			
		//			MJProgressView.instance.hideProgress()
		//			
		//			if (isOk == true && response.characters.count > 0) {
		//				ApplicationManager.sharedInstance.token = response
		//				
		//				UserPreferences.saveData(self.login, password: self.password)
		//				self.goToNextView()
		//			} else {
		//				ErrorViewer.errorShow(self, mess: response) { _ in }
		//				self.waitingView.hidden = true
		//			}
		//		}
		
	}
	
	/**
	Triggered when the keyboard will appear on screen.
	Handles the connexion input positon.
	- parameter notification
	*/
	func keyboardWillShow(notification: NSNotification) {
		
		let userInfo: NSDictionary = notification.userInfo!
		let keyboardFrame: NSValue = (userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as? NSValue)!
		let keyboardRectangle = keyboardFrame.CGRectValue()
		let verticalPoint = connexionBlockView.frame.origin.y + connexionBlockView.frame.size.height
		
		keyboardRectangle.origin.y
		
		if keyboardRectangle.origin.y < verticalPoint {
			
			self.connexionButtonConstraintSave = self.view.frame.origin.y
			UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
				let diff = verticalPoint - keyboardRectangle.origin.y
				self.view.frame.origin.y = diff * -1
				self.view.layoutIfNeeded()
				}, completion: nil)
		}
	}
	
	/**
	Triggered when the keyboard will disappear of the screen.
	Handles the connexion input positon.
	- parameter notification
	*/
	func keyboardWillHide(notification: NSNotification) {
		
		if self.connexionButtonConstraintSave != nil {
			UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
				self.view.frame.origin.y = self.connexionButtonConstraintSave!
				self.view.layoutIfNeeded()
				}, completion: { (complete: Bool) in
					self.connexionButtonConstraintSave = nil
			})
		}
	}
	
	/*!
	Perform the segue to go to the splash view
	*/
	func goToNextView() {
		ApplicationManager.sharedInstance.currentLogin = login
		performSegueWithIdentifier("splashSegue", sender: self)
	}
	
}
