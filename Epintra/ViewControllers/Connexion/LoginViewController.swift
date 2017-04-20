//
//  LoginViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

    @IBOutlet weak var loginTableView: UITableView!
    @IBOutlet weak var loginButton: ActionButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var connexionBlockView: UIView!

    @IBOutlet weak var oauthButton: ActionButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // Used for moving the view
    private var connexionButtonConstraintSave: CGFloat?

    fileprivate let viewModel = LoginViewModel()
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

//        if let credentials = KeychainUtil.getCredentials() {
//            self.addWaitingView()
//            self.login = credentials.email
//            if let tmpPassword = credentials.password {
//                // User used traditional authentication
//                self.password = tmpPassword
//                loginCall()
//            }
//
//        }

        self.registerForKeyboardNotifications()

        checkStatus()

        self.setSubViewsProperties()
        self.setReactive()
    }

    private func setSubViewsProperties() {
        self.view.backgroundColor = UIUtils.backgroundColor

        // Set UITableView properties
        self.loginTableView.register(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "loginCell")
        self.loginTableView.isScrollEnabled = false
        self.loginTableView.layer.cornerRadius = 3
        self.loginTableView.separatorInset = UIEdgeInsets.zero

        // Set different texts
        self.loginButton.setTitle(NSLocalizedString("login", comment: ""), for: UIControlState())
        self.oauthButton.setTitle(NSLocalizedString("officeAuth", comment: ""), for: UIControlState())
        self.infoLabel.text = NSLocalizedString("noOfficialApp", comment: "")
    }

    override func viewDidAppear(_ animated: Bool) {

//        self.removeWaitingView()
//        if let credentials = KeychainUtil.getCredentials() {
//            self.addWaitingView()
//            if let token = credentials.token {
//                ApplicationManager.sharedInstance.token = token
//                ApplicationManager.sharedInstance.user = Variable<User>(User(login: self.login))
//                // Check if token is valid
//                self.checkTokenValidity()
//            }
//        }
//
//        if let waitingview = self.getWaitingView() {
//            MJProgressView.instance.showProgress(waitingview, white: true)
//        } else {
//            MJProgressView.instance.hideProgress()
//        }

    }

    private func setReactive() {

        // Bind button to Rx to enable it
        self.viewModel.isValid.map { $0 }.bindTo(self.loginButton.rx.isEnabled).addDisposableTo(self.disposeBag)

        // Bind tap action to viewmodel to trigger network call
        self.viewModel.bindResponse(action: self.loginButton.rx.tap.asObservable())

        // Subscribe to authentication response and handle it
        self.viewModel.authResponse?
            .subscribe(onNext: { [weak self] response in
            self?.viewModel.isAuthenticating.value = false
            switch response {
            case .success(_):
                try? self?.viewModel.saveCurrentCredentials()
                self?.goToNextView()
            case .failure(let error):
                self?.showError(withMessage: error.message)
            }
        }).addDisposableTo(self.disposeBag)

        // Know if we are authenticating to add
        self.viewModel.isAuthenticating.asObservable().subscribe { value in
            (value.element ?? false) ? MJProgressView.instance.showLoginProgress(self.loginButton, white: true) : MJProgressView.instance.hideProgress()
            }
            .addDisposableTo(self.disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let navigation = segue.destination as? UINavigationController, let vc = navigation.viewControllers.first as? OAuthViewController {
            vc.oAuthDelegate = self
        }
    }

    /**
     Register Notification to get when keyboard is shown and hidden.
     */
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnView(_:)))
        self.view.addGestureRecognizer(gesture)
    }

    func tapOnView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func oauthPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "oAuthSegue", sender: nil)
    }

    /// Check if the current token is still valid by calling a light endpoint.
    /// If so, we go to the next storyboard.
    /// Otherwise, we delete all credentials and remove the waiting view to let user connect again.
    private func checkTokenValidity() {

        MJProgressView.instance.showLoginProgress(self.loginButton, white: true)
        usersRequests.getPhotoURL(ApplicationManager.sharedInstance.user?.value.login ?? "") { [weak self] result in
            MJProgressView.instance.hideProgress()

            guard let tmpSelf = self else {
                return
            }

            switch (result) {
            case .success(_):
                // Token is still valid, we go to the main storyboard
                tmpSelf.goToNextView()
                break
            case .failure(_):
                // Token not valid, user should reconnect
                tmpSelf.removeWaitingView()
                KeychainUtil.deleteCredentials()
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

    /// Check the status of the API and the intranet
    private func checkStatus() {

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

        if indexPath.row == 0 {
            cell?.dataTextField.placeholder = NSLocalizedString("email", comment: "")
            cell?.dataTextField.keyboardType = .emailAddress
            cell?.dataTextField.rx.text.bindTo(self.viewModel.userEmail).addDisposableTo(self.disposeBag)
        } else {
            cell?.dataTextField.placeholder = NSLocalizedString("password", comment: "")
            cell?.dataTextField.isSecureTextEntry = true
            cell?.dataTextField.rx.text.bindTo(self.viewModel.userPassword).addDisposableTo(self.disposeBag)
        }

        cell?.layoutMargins.left = 0

        return cell!
    }
}

extension LoginViewController: OAuthDelegate {
    internal func authentified(withEmail email: String?, andToken token: String?) {

        guard let email = email, let token = token else {
            ErrorViewer.errorShow(self, mess: NSLocalizedString("oauthWrongCredentials", comment: "")) { _ in }
            return
        }
        
        do {
            let auth = Authentication(fromCredentials: email, token: token)
            try KeychainUtil.save(credentials: auth)
        } catch {
            log.error("Thrown error when saving credentials")
        }
        
        ApplicationManager.sharedInstance.token = token
        ApplicationManager.sharedInstance.user = Variable<User>(User(login: email))
        
        DispatchQueue.main.async {
            self.goToNextView()
        }
    }
}
