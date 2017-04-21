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

        self.registerForKeyboardNotifications()
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

    private func setReactive() {

        // Bind button to Rx to enable it
        self.viewModel.isValid.map { $0 }.bindTo(self.loginButton.rx.isEnabled).addDisposableTo(self.disposeBag)

        // Bind tap action to viewmodel to trigger network call
        self.viewModel.bindResponse(action: self.loginButton.rx.tap.asObservable())

        // Subscribe to authentication response and handle it
        self.viewModel.authResponse?
            .subscribe(onNext: { [weak self] response in
            switch response {
            case .success(_):
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
