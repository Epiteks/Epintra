//
//  LoginViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTableView: UITableView!
    @IBOutlet weak var loginButton: ActionButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var connexionBlockView: UIView!

    var login = String()
    var password = String()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // Used for moving the view
    var connexionButtonConstraintSave: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let credentials = KeychainUtil.getCredentials() {
            self.addWaitingView()
            login = credentials.email
            password = credentials.password
            loginCall()
        }

        self.view.backgroundColor = UIUtils.backgroundColor

        // Set UITableView properties
        self.loginTableView.register(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "loginCell")
        self.loginTableView.isScrollEnabled = false
        self.loginTableView.layer.cornerRadius = 3
        self.loginTableView.separatorInset = UIEdgeInsets.zero

        // Set different texts
        self.loginButton.setTitle(NSLocalizedString("login", comment: ""), for: UIControlState())
        self.infoLabel.text = NSLocalizedString("noOfficialApp", comment: "")

        self.registerForKeyboardNotifications()

        checkStatus()
    }

    override func viewDidAppear(_ animated: Bool) {

        self.removeWaitingView()
        if KeychainUtil.getCredentials() != nil {
            self.addWaitingView()
        }

        if let waitingview = self.getWaitingView() {
            MJProgressView.instance.showProgress(waitingview, white: true)
        } else {
            MJProgressView.instance.hideProgress()
        }

    }

    /**
     Register Notification to get when keyboard is shown and hidden.
     */
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapOnView(_:)))
        self.view.addGestureRecognizer(gesture)
    }

    func tapOnView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func loginPressed(_ sender: AnyObject) {

        self.view.endEditing(true)

        // Getting login cell data
        var cell = loginTableView.cellForRow(at: IndexPath(row: 0, section: 0))
        var textField = cell?.viewWithTag(1) as! UITextField
        login = textField.text!

        // Getting password cell data
        cell = loginTableView.cellForRow(at: IndexPath(row: 1, section: 0))
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
        usersRequests.auth(login, password: password) { [weak self] result in
            MJProgressView.instance.hideProgress()

            guard let tmpSelf = self else {
                return
            }

            switch (result) {
            case .success(_):

                do {
                    try KeychainUtil.saveCredentials(email: tmpSelf.login, password: tmpSelf.password)
                } catch {
                    log.error("Thrown error when saving credentials")
                }

                tmpSelf.goToNextView()
                break
            case .failure(let error):
                if (error.type == AppError.authenticationFailure) {
                    ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("invalidCombinaison", comment: "")) { _ in }
                } else if (error.type == AppError.apiError) {
                    if let mess = error.message {
                        ErrorViewer.errorShow(tmpSelf, mess: mess) { _ in }
                    } else {
                        ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("unknownApiError", comment: "")) { _ in }
                    }
                }
                tmpSelf.removeWaitingView()
                break
            }
        }
    }

    /**
     Triggered when the keyboard will appear on screen.
     Handles the connexion input positon.
     - parameter notification
     */
    func keyboardWillShow(_ notification: Notification) {

        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame: NSValue = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue)!
        let keyboardRectangle = keyboardFrame.cgRectValue
        let verticalPoint = connexionBlockView.frame.origin.y + connexionBlockView.frame.size.height

        if keyboardRectangle.origin.y < verticalPoint {

            self.connexionButtonConstraintSave = self.view.frame.origin.y
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
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
    func keyboardWillHide(_ notification: Notification) {

        if self.connexionButtonConstraintSave != nil {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                self.view.frame.origin.y = self.connexionButtonConstraintSave!
                self.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.connexionButtonConstraintSave = nil
            })
        }
    }

    /*!
     Perform the segue to go to the splash view
     */
    func goToNextView() {
        let storyboard = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.present(vc!, animated: true, completion: nil)
    }

    func addWaitingView() {
        let wview = UIView(frame: self.view.frame)
        wview.backgroundColor = UIUtils.backgroundColor
        wview.restorationIdentifier = "waitingview"
        self.view.addSubview(wview)
    }

    func getWaitingView() -> UIView? {
        for sub in self.view.subviews {
            if sub.restorationIdentifier == "waitingview" {
                return sub
            }
        }
        return nil
    }

    func removeWaitingView() {
        if let waitview = self.getWaitingView() {
            waitview.removeFromSuperview()
        }
    }

    func checkStatus() {

        func checkAPI() {
            miscRequests.getAPIStatus { [weak self] responseAPI in

                guard let tmpSelf = self else {
                    return
                }

                switch responseAPI {
                case .success(let status):
                    if status {
                        checkIntra()
                    } else {
                        ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("serverNotAvailable", comment: "")) { _ in }
                    }
                    break
                case .failure(let error):
                    if let mess = error.message {
                        ErrorViewer.errorShow(tmpSelf, mess: mess) { _ in }
                    } else {
                        ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("unknownApiError", comment: "")) { _ in }
                    }
                    break
                }
            }
        }

        func checkIntra() {
            miscRequests.getIntraStatus(completion: { [weak self] responseIntra in

                guard let tmpSelf = self else {
                    return
                }

                switch responseIntra {
                case .success(let status):
                    if !status {
                        ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("serverNotAvailable", comment: "")) { _ in }
                    }
                    break
                case .failure(let error):
                    if let mess = error.message {
                        ErrorViewer.errorShow(tmpSelf, mess: mess) { _ in }
                    } else {
                        ErrorViewer.errorShow(tmpSelf, mess: NSLocalizedString("unknownApiError", comment: "")) { _ in }
                    }
                    break
                }
            })
        }

        checkAPI()
    }
}

extension LoginViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell") as? LoginTableViewCell

        cell?.dataTextField.tintColor = UIUtils.backgroundColor

        if ((indexPath as NSIndexPath).row == 0) {
            cell?.dataTextField.placeholder = NSLocalizedString("email", comment: "")
            cell?.dataTextField.keyboardType = .emailAddress
        } else {
            cell?.dataTextField.placeholder = NSLocalizedString("password", comment: "")
            cell?.dataTextField.isSecureTextEntry = true
        }

        cell?.layoutMargins.left = 0

        return cell!
    }
}

extension LoginViewController {

    //    func getUserDataAndGoNext() {
    //
    //        usersRequests.getCurrentUserData { result in
    //            switch (result) {
    //            case .success(_):
    //                log.info("Get user data ok")
    //            case .failure(let error):
    //                DispatchQueue.main.async {
    //                    self.errorDuringFetching = true
    //                    MJProgressView.instance.hideProgress()
    //                    if error.message != nil {
    //                        ErrorViewer.errorPresent(self, mess: error.message!) {
    //                            group.leave()
    //                        }
    //                    } else {
    //                        ErrorViewer.errorPresent(self, mess: NSLocalizedString("unknownApiError", comment: "")) {
    //                            group.leave()
    //                        }
    //                    }
    //                }
    //                break
    //            }
    //        }
    //    }
}
