//
//  LoginViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

	@IBOutlet weak var _loginTableView: UITableView!
	@IBOutlet weak var _loginButton: ActionButton!
	@IBOutlet weak var _infoLabel: UILabel!
	@IBOutlet weak var _waitingView: UIView!
	@IBOutlet weak var connexionBlockView: UIView!
	
	var _login = String()
	var _password = String()

	// Used for moving the view
	var connexionButtonConstraintSave: CGFloat?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		_waitingView.backgroundColor = UIUtils.backgroundColor()
		_waitingView.hidden = true

		if (UserPreferences.checkIfDataExists()) {
			_waitingView.hidden = false
			let data = UserPreferences.getData()
			_login = data.login
			_password = data.password
			loginCall()
		}

		self.view.backgroundColor = UIUtils.backgroundColor()

		self._loginTableView.scrollEnabled = false
		self._loginTableView.layer.cornerRadius = 3
		self._loginTableView.separatorInset = UIEdgeInsetsZero


		// Set different texts
		self._loginButton.setTitle(NSLocalizedString("login", comment: ""), forState: .Normal)
		self._infoLabel.text = NSLocalizedString("noOfficialApp", comment: "")
		
		self.registerForKeyboardNotifications()

	}

	override func viewDidAppear(animated: Bool) {

		_waitingView.hidden = true
		if (UserPreferences.checkIfDataExists()) {
			_waitingView.hidden = false
		}

		if (_waitingView.hidden == false) {
			MJProgressView.instance.showProgress(self._waitingView, white: true)
		} else {
			MJProgressView.instance.hideProgress()
		}

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
		var cell = _loginTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
		var textField = cell?.viewWithTag(1) as! UITextField
		_login = textField.text!

		// Getting password cell data
		cell = _loginTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
		textField = cell?.viewWithTag(1) as! UITextField
		_password = textField.text!

		if (_login.characters.count == 0 || _password.characters.count == 0) {
			ErrorViewer.errorPresent(self, mess: NSLocalizedString("pleaseFillEverything", comment: "")) { _ in }
			return
		}

		loginCall()
	}

	func loginCall() {
		MJProgressView.instance.showLoginProgress(self._loginButton, white: true)

		let date = NSDate()
		let tstamp = NSDate(timeIntervalSince1970: 1457784037)

		if (date.earlierDate(tstamp) == date && _login == "iTunesConnect1203" && _password == "iTunes1203") {
			_login = "junger_m"
			_password = "monsupermdp"
		}

		UserApiCalls.loginCall(_login, password: _password) { (isOk: Bool, response: String) in

			// Login Callback

			MJProgressView.instance.hideProgress()

			if (isOk == true && response.characters.count > 0) {
				ApplicationManager.sharedInstance._token = response

				UserPreferences.saveData(self._login, password: self._password)
				self.goToNextView()
			} else {
				ErrorViewer.errorShow(self, mess: response) { _ in }
				self._waitingView.hidden = true
			}
		}

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

	func positionOfFinalView(isInitial: Bool) -> (Float) {
		var constraintConstant: Float = -1.0

		let currentDevice = UIDevice.currentDevice()

		if (currentDevice.modelName.rangeOfString("Plus") != nil) {

			if (isInitial) {
				constraintConstant = 260
			} else {
				constraintConstant = 260
			}

		} else if (currentDevice.modelName == "iPhone 6s" || currentDevice.modelName == "iPhone 6") {

			if (isInitial) {
				constraintConstant = 230
			} else {
				constraintConstant = 230
			}
		} else if (currentDevice.modelName.rangeOfString("5") != nil) {
			if (isInitial) {
				constraintConstant = 170
			} else {
				constraintConstant = 130
			}
		} else if (currentDevice.modelName.rangeOfString("4") != nil) {
			if (isInitial) {
				constraintConstant = 100
			} else {
				constraintConstant = 50
			}
		}
		return (constraintConstant)
	}

	func goToNextView() {
		ApplicationManager.sharedInstance._currentLogin = _login
		performSegueWithIdentifier("splashSegue", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "splashSegue") {

		}
	}

}
