//
//  SplashScreenViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 22/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {

        guard let credentials = KeychainUtil.getCredentials(), credentials.token != nil else {
            // Should go back to login view controller
            return
        }

        // Can go to menu controller
        let sb = UIStoryboard(name: "MainViewStoryboard", bundle: nil)
        let menuVC = sb.instantiateViewController(withIdentifier: "mainMenuVC")
        self.present(menuVC, animated: false, completion: nil)

    }

}
